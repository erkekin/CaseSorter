const core = require('@actions/core');
// const github = require('@actions/github');

try {
  const filesToSort = core.getInput('files');
  const { execSync } = require('child_process');
  execSync('curl -sL https://github.com/erkekin/CaseSorter/releases/download/v1/casesorter.tar | tar xz');
  execSync('chmod u+x ./Users/eekin/.casesorter/x86_64-apple-macosx/release/caseSorter-swift');
  execSync('./Users/eekin/.casesorter/x86_64-apple-macosx/release/caseSorter-swift ' + filesToSort);
  execSync('rm -rf Users');

  // const payload = JSON.stringify(github.context.payload, undefined, 2)
  // console.log(`The event payload: ${payload}`);
} catch (error) {
  core.setFailed(error.message);
}