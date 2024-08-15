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
