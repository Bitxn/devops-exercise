# CI/CD Tools — Comparison

| # | Tool | Overview | Best for | Website |
|---|------|----------|----------|---------|
| 1 | **GitLab CI/CD** | Built into GitLab; YAML pipelines; Auto DevOps. | Teams on GitLab for version control. | https://gitlab.com |
| 2 | **CircleCI** | Cloud CI/CD; container-based; parallelism & caching; native Docker. | Container-heavy workflows. | https://circleci.com |
| 3 | **Travis CI** | YAML config; many languages; easy GitHub integration. | Open-source projects, small teams. | https://travis-ci.org |
| 4 | **Bamboo** | Atlassian CI/CD; deep JIRA/Bitbucket integration. | Teams in the Atlassian ecosystem. | https://www.atlassian.com/software/bamboo |
| 5 | **TeamCity** | JetBrains server; rich history/reports; many runners & plugins. | Complex enterprise CI/CD. | https://www.jetbrains.com/teamcity |
| 6 | **Azure DevOps (Pipelines)** | Microsoft suite; YAML or classic editor; multi-platform. | Teams on Azure cloud. | https://azure.microsoft.com/en-us/services/devops/ |
| 7 | **GitHub Actions** | YAML workflows; big marketplace; deep GitHub integration. | Teams on GitHub. | https://github.com/features/actions |
| 8 | **Spinnaker** | Open-source continuous delivery; multi-cloud; canary/blue-green. | Complex cloud-native deployments. | https://spinnaker.io |
| 9 | **Buildkite** | Hybrid: cloud management + self-hosted agents; parallel builds. | Teams with security concerns about fully-cloud CI. | https://buildkite.com |
| 10 | **Drone** | Lightweight, container-native pipelines; open-source. | Teams preferring container-based workflows. | https://www.drone.io |

## How to choose
- **Already on a platform?** Use its native CI (GitHub → Actions, GitLab → GitLab CI,
  Atlassian → Bamboo). Least setup, tightest integration.
- **Container-first?** CircleCI, Drone, or Buildkite.
- **Enterprise scale / detailed reporting?** TeamCity or Azure DevOps.
- **Advanced cloud deployment strategies?** Spinnaker.
- **Self-hosted automation engine with max flexibility?** Jenkins (see the main README).
