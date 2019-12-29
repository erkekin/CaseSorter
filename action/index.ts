import * as core from "@actions/core"
import * as github from "@actions/github"

class ChangedFiles {
    updated: Array<string> = []
    created: Array<string> = []
    deleted: Array<string> = []
}

function getPrNumber(): number | null {
    console.log(github.context.payload.pull_request)
    const pullRequest = github.context.payload.pull_request
    return pullRequest ? pullRequest.number : null
}

async function getChangedFiles(client: github.GitHub, prNumber: number): Promise<ChangedFiles> {
    const listFilesResponse = await client.pulls.listFiles({
        owner: github.context.repo.owner,
        repo: github.context.repo.repo,
        pull_number: prNumber,
    })

    console.log("Found changed files:")
    return listFilesResponse.data.reduce((acc: ChangedFiles, f) => {
        console.log(f)
        if (f.status === "added") {
            acc.created.push(f.filename)
        } else if (f.status === "removed") {
            acc.deleted.push(f.filename)
        } else if (f.status === "modified") {
            acc.updated.push(f.filename)
        } else if (f.status === "renamed") {
            acc.created.push(f.filename)
            acc.deleted.push(f["previous_filename"])
        }
        return acc
    }, new ChangedFiles())
}

async function run(): Promise<void> {
    try {
        const token = core.getInput("repo-token", { required: true })
        const client = new github.GitHub(token)
        const prNumber = getPrNumber()
        if (prNumber == null) {
            core.setFailed("Could not get pull request number from context, exiting")
            return
        }

        const filesToSort = core.getInput("files")
        const { execSync } = require("child_process")
        execSync("curl -sL https://github.com/erkekin/CaseSorter/releases/download/v1/casesorter.tar | tar xz")
        execSync("chmod u+x ./Users/eekin/.casesorter/x86_64-apple-macosx/release/caseSorter-swift")
        execSync("./Users/eekin/.casesorter/x86_64-apple-macosx/release/caseSorter-swift " + filesToSort)
        execSync("rm -rf Users")
        core.debug(`Fetching changed files for pr #${prNumber}`)
        const changedFiles = await getChangedFiles(client, prNumber)

        // core.setOutput("files_created", changedFiles.created.join(" "))
        // core.setOutput("files_updated", changedFiles.updated.join(" "))
        // core.setOutput("files_deleted", changedFiles.deleted.join(" "))

        console.log(`The event created: ${changedFiles.created.join(" ")}`)
        console.log(`The event updated: ${changedFiles.updated.join(" ")}`)
        console.log(`The event deleted: ${changedFiles.deleted.join(" ")}`)
    } catch (error) {
        core.setFailed(error.message)
    }
}

run()
