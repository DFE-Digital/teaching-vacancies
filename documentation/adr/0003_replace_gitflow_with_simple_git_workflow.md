# Replace Gitflow with Simple Git Workflow

Date: 23/01/2020

## Prologue (Summary)

We currently use a [gitflow](https://datasift.github.io/gitflow/IntroducingGitFlow.html) model for branching and
release. It is intended to keep long-lived feature branches isolated from master at the cost of additional complexity in
keeping the development branch and the master branch in sync. Given the simplicity of the service, our collective desire
to cut down on irregular maintenance tasks (like merging develop into master manually to release new code), and our
desire to increase the velocity at which we can release new features, we would benefit from moving to a [simplified git
workflow](https://www.atlassian.com/git/articles/simple-git-workflow-is-simple).

### Status: **TBD**

## Discussion (Context)

Changing our git workflow is straightforward. All we need is agreement between the devs on changing to a different
approach. However, complexity arises owing to the setup of our [AWS
Codebuild](https://eu-west-2.console.aws.amazon.com/codesuite/codebuild/projects?region=eu-west-2) environment. In
addition to the project, which is attached to our GitHub repo, there are five different build projects:

https://eu-west-2.console.aws.amazon.com/codesuite/codebuild/projects/tvs2-pull-requests/history?region=eu-west-2

https://eu-west-2.console.aws.amazon.com/codesuite/codebuild/projects/tvs2-production-codebuild/history?region=eu-west-2

https://eu-west-2.console.aws.amazon.com/codesuite/codebuild/projects/tvs2-testing-codebuild/history?region=eu-west-2

https://eu-west-2.console.aws.amazon.com/codesuite/codebuild/projects/tvs2-edge-codebuild/history?region=eu-west-2

https://eu-west-2.console.aws.amazon.com/codesuite/codebuild/projects/tvs2-staging-codebuild/history?region=eu-west-2

and four different pipelines: 

https://eu-west-2.console.aws.amazon.com/codesuite/codepipeline/pipelines/tvs2-production-pipeline/view?region=eu-west-2

https://eu-west-2.console.aws.amazon.com/codesuite/codepipeline/pipelines/tvs2-staging-pipeline/view?region=eu-west-2

https://eu-west-2.console.aws.amazon.com/codesuite/codepipeline/pipelines/tvs2-edge-pipeline/view?region=eu-west-2

https://eu-west-2.console.aws.amazon.com/codesuite/codepipeline/pipelines/tvs2-testing-pipeline/view?region=eu-west-2

They are each triggered by self-named branches in GitHub. At the time of writing, `edge` hasn't be triggered in 10 days
and `testing` hasn't been triggered for three months. 

We need to plan to remove all of these that correspond to branches we intend to stop using.


## Solution

## Consequences
