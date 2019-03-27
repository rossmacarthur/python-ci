import subprocess

import mock
from click.testing import CliRunner

from ci import __version__, cli


def test_cli_version():
    runner = CliRunner()
    result = runner.invoke(cli, ['--version'])
    assert result.exit_code == 0
    assert result.output == 'ci {version}\n'.format(version=__version__)


def test_cli_mutually_exclusive():
    runner = CliRunner()
    result = runner.invoke(cli, ['--skip', 'test', '--only', 'test2'])
    assert result.exit_code != 0
    assert result.output.endswith('Error: --only and --skip are mutually exclusive\n')


def test_cli_only():
    runner = CliRunner()

    with mock.patch('platform.python_version', return_value='test'):
        subprocess.call = mock.MagicMock(return_value=1)
        result = runner.invoke(cli, ['--only', 'derp', 'fakecmd'])
        assert result.exit_code == 0
        assert result.output == ''
        assert not subprocess.call.called

        subprocess.call = mock.MagicMock(return_value=0)

        result = runner.invoke(cli, ['--only', 'test', 'fakecmd'])
        assert result.exit_code == 0
        assert result.output == 'ci: fakecmd\nci: exiting with 0\n'
        assert subprocess.call.called_with(('fakecmd',), False)


def test_cli_skip():
    runner = CliRunner()

    with mock.patch('platform.python_version', return_value='test'):
        subprocess.call = mock.MagicMock(return_value=1)
        result = runner.invoke(cli, ['--skip', 'test', 'fakecmd'])
        assert result.exit_code == 0
        assert result.output == ''
        assert not subprocess.call.called

        subprocess.call = mock.MagicMock(return_value=0)
        result = runner.invoke(cli, ['--skip', 'derp', 'fakecmd'])
        assert result.exit_code == 0
        assert result.output == 'ci: fakecmd\nci: exiting with 0\n'
        assert subprocess.call.called_with(('fakecmd',), False)
