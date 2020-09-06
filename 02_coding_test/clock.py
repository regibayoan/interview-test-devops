from apscheduler.schedulers.blocking import BlockingScheduler
from message import send_message

sched = BlockingScheduler()

# Schedule job_function to be called every two hours
sched.add_job(send_message, 'interval', seconds=10)

sched.start()

