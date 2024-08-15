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
