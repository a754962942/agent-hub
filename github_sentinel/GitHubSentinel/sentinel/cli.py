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
