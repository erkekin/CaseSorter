import * as core from "@actions/core"
// import * as github from "@actions/github"

async function run(): Promise<void> {
    try {

        const filesToSort = core.getInput("files")
        
        const { execSync } = require("child_process")
        execSync("curl -sL https://github.com/erkekin/CaseSorter/releases/download/v1/casesorter.tar | tar xz")
        execSync("chmod u+x ./Users/eekin/.casesorter/x86_64-apple-macosx/release/caseSorter-swift")
        execSync("./Users/eekin/.casesorter/x86_64-apple-macosx/release/caseSorter-swift " + filesToSort)
        execSync("rm -rf Users")

    } catch (error) {
        core.setFailed(error.message)
    }
}

run()
