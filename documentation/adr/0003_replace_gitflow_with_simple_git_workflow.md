# Replace Gitflow with Simple Git Workflow

Date: 23/01/2020

## Prologue (Summary)

We currently use a [gitflow](https://datasift.github.io/gitflow/IntroducingGitFlow.html) model for branching and
release. It is intended to keep long-lived feature branches isolated from main at the cost of additional complexity in
keeping the development branch and the main branch in sync. Given the simplicity of the service, our collective desire
to cut down on irregular maintenance tasks (like merging develop into main manually to release new code), and our
desire to increase the velocity at which we can release new features, we would benefit from moving to a [simplified git
workflow](https://www.atlassian.com/git/articles/simple-git-workflow-is-simple).

### Status: **discussing**

## Discussion (Context)

We want to move to a continuous delivery (CD) model, which would allow us to release new features and fixes as quickly
as we write them and put them through our QA process. This ambition is hampered by having an intermediate `development`
branch that is intended to isolate 'new development from finished work' ('Parallel Development'
https://datasift.github.io/gitflow/IntroducingGitFlow.html). We should not fear releasing unfinished work, but instead
should control it via application level routing and/or feature flags. This would enable us to be much more reactive to
feature requests from our users and findings made during our user research.

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

We need to plan to remove all of these that correspond to branches we intend to stop using. While these are not tightly
coupled dependencies, there are cost and maintenance implications to leaving orphaned resources in AWS.

## Solution

1) Remove all long-lived branches, and their supporting pipelines and build integrations, except `main`.
1) Ensure that `main` remains a protected branch on GitHub that requires PRs and passing CI tests.
1) Brief all the team to ensure they understand their responsibilities:
  1) All code must have at least happy path tests (we have started explicitly putting this in acceptance criteria)
  1) All new code that changes existing production workflows must be set up in such a way that it can be switched on and
  off on production (feature flags).
  1) Any epic that includes feature flags must include an end-of-epic ticket to remove the feature flagging code after
  successful launch.
1) Review, expand and better expose our error monitoring tools so we can keep track of our defect rate as we increase
our release velocity.
1) Adapt the staging pipeline to allow it to be built on-demand. For example it might build stating if sees a push with
the tag `staging`. This will allow devs to build staging for sign off by Product and other stakeholders.

## Consequences

We will almost certainly see more defects reach production. However, the defect rate will probably go down as we get
used to the new workflow. We will also be much better placed to fix things as we become aware of them.
