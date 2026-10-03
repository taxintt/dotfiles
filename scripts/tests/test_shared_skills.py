import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[2]
SKILLS = ('golang-patterns', 'golang-testing', 'terraform-validation')


class SharedSkillsTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        root = Path(self.temp.name).resolve()
        self.repo = root / 'repo'
        shutil.copytree(REPO, self.repo, symlinks=True, ignore=shutil.ignore_patterns('.git', '__pycache__'))
        self.home = root / 'home'
        for directory in ('.config/ghostty', '.config/mise', '.claude/skills/external', '.codex/skills/.system', '.agents/skills/external'):
            (self.home / directory).mkdir(parents=True, exist_ok=True)
        (self.home / '.agents/skills/external/SKILL.md').write_text('external')
        (self.home / '.claude/skills/external/SKILL.md').write_text('external')
        (self.home / '.codex/skills/.system/marker').write_text('system')

    def install(self):
        return subprocess.run(['sh', str(self.repo / 'scripts/link.sh')], env=dict(os.environ, HOME=str(self.home)), capture_output=True, text=True)

    def test_install_and_repeat_preserve_external_skills(self):
        for _ in range(2):
            result = self.install()
            self.assertEqual(result.returncode, 0, result.stderr)
            for name in SKILLS:
                shared = self.repo / 'agent-assets/skills' / name
                codex = self.home / '.agents/skills' / name
                claude = self.home / '.claude/skills' / name
                self.assertEqual(codex.resolve(), shared)
                self.assertEqual((claude / 'shared').resolve(), shared)
                self.assertEqual((codex / 'instructions.md').read_bytes(), (claude / 'shared/instructions.md').read_bytes())
                for reference in shared.glob('*.md'):
                    self.assertEqual(reference.read_bytes(), (claude / 'shared' / reference.name).read_bytes())
        self.assertEqual((self.home / '.agents/skills/external/SKILL.md').read_text(), 'external')
        self.assertEqual((self.home / '.claude/skills/external/SKILL.md').read_text(), 'external')
        self.assertEqual((self.home / '.codex/skills/.system/marker').read_text(), 'system')

    def test_unmanaged_collisions_are_preserved(self):
        for location in ('.agents/skills', '.claude/skills'):
            for kind in ('file', 'directory', 'symlink', 'dangling'):
                with self.subTest(location=location, kind=kind):
                    target = self.home / location / 'golang-patterns'
                    if kind == 'file':
                        target.write_text('keep')
                    elif kind == 'directory':
                        target.mkdir()
                        (target / 'marker').write_text('keep')
                    else:
                        target.symlink_to('missing' if kind == 'dangling' else 'external')
                    try:
                        result = self.install()
                        self.assertNotEqual(result.returncode, 0)
                        self.assertIn(str(target), result.stderr)
                        self.assertFalse((self.home / '.zshrc').is_symlink())
                        if kind == 'directory':
                            self.assertEqual((target / 'marker').read_text(), 'keep')
                        elif kind == 'file':
                            self.assertEqual(target.read_text(), 'keep')
                        else:
                            self.assertEqual(os.readlink(target), 'missing' if kind == 'dangling' else 'external')
                    finally:
                        if target.is_dir() and not target.is_symlink():
                            shutil.rmtree(target)
                        else:
                            target.unlink()

    def test_reclone_replaces_existing_managed_links(self):
        self.assertEqual(self.install().returncode, 0)
        old = self.repo
        self.repo = old.parent / 'reclone'
        shutil.copytree(old, self.repo, symlinks=True)
        self.assertEqual(self.install().returncode, 0)
        for name in SKILLS:
            self.assertEqual((self.home / '.agents/skills' / name).resolve(), self.repo / 'agent-assets/skills' / name)
            self.assertEqual((self.home / '.claude/skills' / name).resolve(), self.repo / '.claude/skills' / name)

    def test_move_replaces_dangling_managed_links(self):
        self.assertEqual(self.install().returncode, 0)
        relocated = self.repo.parent / 'moved'
        self.repo.rename(relocated)
        self.repo = relocated
        self.assertEqual(self.install().returncode, 0)
        for name in SKILLS:
            self.assertEqual((self.home / '.agents/skills' / name).resolve(), self.repo / 'agent-assets/skills' / name)
            self.assertEqual((self.home / '.claude/skills' / name).resolve(), self.repo / '.claude/skills' / name)

    def test_symlinked_repository_path(self):
        self.assertEqual(self.install().returncode, 0)
        alias = self.repo.parent / 'alias'
        alias.symlink_to(self.repo)
        result = subprocess.run(['sh', str(alias / 'scripts/link.sh')], env=dict(os.environ, HOME=str(self.home)), capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        for name in SKILLS:
            self.assertEqual((self.home / '.agents/skills' / name).resolve(), self.repo / 'agent-assets/skills' / name)

    def test_metadata_and_neutral_body(self):
        for name in SKILLS:
            claude = (self.repo / '.claude/skills' / name / 'SKILL.md').read_text()
            codex = (self.repo / 'agent-assets/skills' / name / 'SKILL.md').read_text()
            body = (self.repo / 'agent-assets/skills' / name / 'instructions.md').read_text()
            self.assertIn('model: sonnet', claude)
            self.assertIn('shared/instructions.md', claude)
            self.assertIn('instructions.md', codex)
            self.assertNotIn('model:', codex)
            for dependency in ('go-reviewer', 'PostToolUse', 'Stop hook', 'terraform-code-generation', 'tdd-workflow/'):
                self.assertNotIn(dependency, body)


if __name__ == '__main__':
    unittest.main()
