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
