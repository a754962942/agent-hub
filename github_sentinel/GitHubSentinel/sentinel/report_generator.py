import markdown
import os

class ReportGenerator:
    def __init__(self, report_dir='reports'):
        self.report_dir = report_dir
        if not os.path.exists(report_dir):
            os.makedirs(report_dir)

    def generate_markdown_report(self, repo_name, updates):
        report_content = f"# Report for {repo_name}\n\n"
        for update in updates:
            report_content += f"## {update['type']}\n"
            report_content += f"- Date: {update['created_at']}\n"
            report_content += f"- Details: {update.get('details', 'No details available')}\n\n"

        report_file = os.path.join(self.report_dir, f"{repo_name}_report.md")
        with open(report_file, 'w') as file:
            file.write(report_content)

        print(f"Report generated: {report_file}")

    def convert_to_html(self, markdown_file):
        with open(markdown_file, 'r') as file:
            text = file.read()
            html = markdown.markdown(text)

        html_file = markdown_file.replace('.md', '.html')
        with open(html_file, 'w') as file:
            file.write(html)

        print(f"HTML report generated: {html_file}")
