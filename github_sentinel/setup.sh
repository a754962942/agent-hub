#!/bin/bash

# Define the root directory
ROOT_DIR="GitHubSentinel"

# Create the directory structure
mkdir -p $ROOT_DIR/sentinel
mkdir -p $ROOT_DIR/tests
mkdir -p $ROOT_DIR/scripts

# Create core module files
cat > $ROOT_DIR/sentinel/__init__.py <<EOL
# GitHub Sentinel Core Package
EOL

cat > $ROOT_DIR/sentinel/subscription_manager.py <<EOL
import os
import json

class SubscriptionManager:
    def __init__(self, subscription_file='subscriptions.json'):
        self.subscription_file = subscription_file
        self.subscriptions = self._load_subscriptions()

    def _load_subscriptions(self):
        if os.path.exists(self.subscription_file):
            with open(self.subscription_file, 'r') as file:
                return json.load(file)
        return {}

    def _save_subscriptions(self):
        with open(self.subscription_file, 'w') as file:
            json.dump(self.subscriptions, file, indent=4)

    def add_subscription(self, repo_name):
        if repo_name not in self.subscriptions:
            self.subscriptions[repo_name] = {'last_checked': None}
            self._save_subscriptions()
            print(f'Subscribed to {repo_name}.')
        else:
            print(f'Already subscribed to {repo_name}.')

    def remove_subscription(self, repo_name):
        if repo_name in self.subscriptions:
            del self.subscriptions[repo_name]
            self._save_subscriptions()
            print(f'Unsubscribed from {repo_name}.')
        else:
            print(f'No subscription found for {repo_name}.')

    def list_subscriptions(self):
        if self.subscriptions:
            print("Subscribed Repositories:")
            for repo in self.subscriptions:
                print(f' - {repo}')
        else:
            print("No subscriptions found.")
EOL

cat > $ROOT_DIR/sentinel/update_fetcher.py <<EOL
import requests
from datetime import datetime

class UpdateFetcher:
    def __init__(self, token, subscriptions):
        self.token = token
        self.subscriptions = subscriptions

    def _get_headers(self):
        return {
            'Authorization': f'token {self.token}',
            'Accept': 'application/vnd.github.v3+json',
        }

    def fetch_updates(self, repo_name):
        url = f'https://api.github.com/repos/{repo_name}/events'
        response = requests.get(url, headers=self._get_headers())

        if response.status_code == 200:
            events = response.json()
            latest_event = events[0] if events else None
            return latest_event
        else:
            print(f"Failed to fetch updates for {repo_name}.")
            return None

    def check_for_updates(self):
        for repo_name, details in self.subscriptions.items():
            latest_event = self.fetch_updates(repo_name)
            if latest_event:
                event_time = datetime.strptime(latest_event['created_at'], "%Y-%m-%dT%H:%M:%SZ")
                last_checked = details['last_checked']

                if not last_checked or event_time > datetime.strptime(last_checked, "%Y-%m-%dT%H:%M:%SZ"):
                    print(f"New update found in {repo_name}: {latest_event['type']}")
                    details['last_checked'] = latest_event['created_at']
                    # Here you could notify or save this information.
                else:
                    print(f"No new updates for {repo_name}.")
EOL

cat > $ROOT_DIR/sentinel/notifier.py <<EOL
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

class Notifier:
    def __init__(self, email_config):
        self.email_config = email_config

    def send_email(self, subject, body, to_email):
        msg = MIMEMultipart()
        msg['From'] = self.email_config['from_email']
        msg['To'] = to_email
        msg['Subject'] = subject

        msg.attach(MIMEText(body, 'plain'))

        try:
            server = smtplib.SMTP(self.email_config['smtp_server'], self.email_config['smtp_port'])
            server.starttls()
            server.login(self.email_config['from_email'], self.email_config['password'])
            text = msg.as_string()
            server.sendmail(self.email_config['from_email'], to_email, text)
            server.quit()
            print(f"Email sent to {to_email}.")
        except Exception as e:
            print(f"Failed to send email: {e}")
EOL

cat > $ROOT_DIR/sentinel/report_generator.py <<EOL
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
EOL

cat > $ROOT_DIR/sentinel/scheduler.py <<EOL
import schedule
import time

class Scheduler:
    def __init__(self):
        self.jobs = []

    def schedule_daily(self, func, time_str):
        job = schedule.every().day.at(time_str).do(func)
        self.jobs.append(job)

    def schedule_weekly(self, func, day, time_str):
        job = schedule.every().week.at(time_str).do(func)
        self.jobs.append(job)

    def run_pending(self):
        while True:
            schedule.run_pending()
            time.sleep(1)
EOL

cat > $ROOT_DIR/sentinel/cli.py <<EOL
import click
from sentinel.subscription_manager import SubscriptionManager
from sentinel.update_fetcher import UpdateFetcher
from sentinel.notifier import Notifier
from sentinel.report_generator import ReportGenerator
from sentinel.scheduler import Scheduler

@click.group()
def cli():
    """GitHub Sentinel CLI"""
    pass

@cli.command()
@click.argument('repo_name')
def subscribe(repo_name):
    """Subscribe to a GitHub repository."""
    manager = SubscriptionManager()
    manager.add_subscription(repo_name)

@cli.command()
@click.argument('repo_name')
def unsubscribe(repo_name):
    """Unsubscribe from a GitHub repository."""
    manager = SubscriptionManager()
    manager.remove_subscription(repo_name)

@cli.command()
def list_subscriptions():
    """List all subscriptions."""
    manager = SubscriptionManager()
    manager.list_subscriptions()

@cli.command()
def fetch_updates():
    """Fetch updates for all subscribed repositories."""
    manager = SubscriptionManager()
    fetcher = UpdateFetcher(token='YOUR_GITHUB_TOKEN', subscriptions=manager.subscriptions)
    fetcher.check_for_updates()

@cli.command()
@click.argument('repo_name')
@click.argument('format', default='markdown')
def generate_report(repo_name, format):
    """Generate a report for a repository."""
    generator = ReportGenerator()
    manager = SubscriptionManager()
    fetcher = UpdateFetcher(token='YOUR_GITHUB_TOKEN', subscriptions=manager.subscriptions)
    updates = fetcher.fetch_updates(repo_name)

    if format == 'markdown':
        generator.generate_markdown_report(repo_name, updates)
    elif format == 'html':
        markdown_file = generator.generate_markdown_report(repo_name, updates)
        generator.convert_to_html(markdown_file)

@cli.command()
@click.argument('time_str')
def schedule_daily_updates(time_str):
    """Schedule daily updates."""
    scheduler = Scheduler()
    scheduler.schedule_daily(func=fetch_updates, time_str=time_str)
    scheduler.run_pending()

if __name__ == '__main__':
    cli()
EOL

# Create test module files
for module in subscription_manager update_fetcher notifier report_generator scheduler cli; do
cat > $ROOT_DIR/tests/test_${module}.py <<EOL
import unittest
from sentinel.${module} import *

class Test${module^}(unittest.TestCase):
    def test_placeholder(self):
        self.assertTrue(True)

if __name__ == '__main__':
    unittest.main()
EOL
done

# Create scripts
cat > $ROOT_DIR/scripts/setup.sh <<EOL
#!/bin/bash

# Install required packages
pip install -r requirements.txt
EOL

cat > $ROOT_DIR/scripts/run_sentinel.sh <<EOL
#!/bin/bash

# Run GitHub Sentinel CLI
python sentinel/cli.py "\$@"
EOL

# Create requirements.txt
cat > $ROOT_DIR/requirements.txt <<EOL
click
requests
markdown
schedule
EOL

# Create README.md
cat > $ROOT_DIR/README.md <<EOL
# GitHub Sentinel

GitHub Sentinel is an open-source AI Agent designed for developers and project managers. It automatically retrieves and summarizes the latest updates from subscribed GitHub repositories on a regular basis
EOL