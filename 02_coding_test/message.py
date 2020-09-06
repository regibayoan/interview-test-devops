import os
from dotenv import load_dotenv
from twilio.rest import Client

load_dotenv()

account_sid = 'AC191770330f0d4cae92dd66688b4eadf7' 
auth_token = os.getenv('TWILIO_AUTH_TOKEN')
client = Client(account_sid, auth_token) 
def send_message():
    message = client.messages.create( 
                                from_='whatsapp:+14155238886',  
                                body="Deployed to Heroku. Don't forget to pick up your sister from school at 3pm",   
                                to='whatsapp:+447463710345' 
                            ) 
    
    print(message.sid)

