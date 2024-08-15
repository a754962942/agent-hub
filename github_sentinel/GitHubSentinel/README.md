# GitHub Sentinel
**GitHub Sentinel** 是一款为开发者和项目管理人员量身打造的开源AI Agent，旨在简化跟踪多个GitHub仓库更新的过程。该工具能够自动定期（每日或每周）获取并汇总订阅仓库的最新动态。

通过**GitHub Sentinel**，用户可以轻松管理订阅，及时接收任何更改的通知，并生成详细的报告。它的交互式命令行界面设计简洁高效，能够在后台无缝运行，确保项目始终处于最新状态。

## 主要功能：
- **订阅管理**：轻松订阅或取消订阅GitHub仓库。
- **自动更新获取**：定期从仓库获取更新，确保不会错过任何重要变更。
- **通知系统**：实时提醒用户新的更新和更改。
- **报告生成**：提供详细的Markdown或HTML格式报告，帮助跟踪项目进展。
## 如何开始：
1. ### 克隆项目：

```bash
git clone https://github.com/yourusername/GitHubSentinel.git
cd GitHubSentinel
```
2. ### 安装依赖：
使用以下命令安装所需的Python库：

```bash
pip install -r requirements.txt
```
3. ### 配置GitHub Token：
获取GitHub API Token，并将其添加到配置文件或环境变量中。

4. ### 运行工具：
通过命令行界面运行GitHub Sentinel：

```bash
python sentinel/cli.py subscribe <repo_name>
```
5. ### 定期获取更新：
使用脚本或计划任务定期运行更新获取命令，以确保项目始终保持最新。

GitHub Sentinel是开发者和管理人员的理想助手，有助于提高协作效率，并保持对项目动态的高度关注。