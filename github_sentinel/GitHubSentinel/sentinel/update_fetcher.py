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
