import json
import boto3
import os
from datetime import datetime
from datetime import date
from datetime import timedelta
import random
import time

#Global Vars
retry_interval_seconds = 15

#boto objects


def lambda_handler(event, context):


    hour_min = os.environ['hour_min'] #minimum hours of next execution window
    hour_max = os.environ['hour_max'] #minimum hours of next execution window
    repetition_days = os.environ['repetition_days'] #repetition of execution window in days
    rule_name = os.environ['rule_name'] #name of the rule to edit
    region_list = os.environ['region_list'] #regions to change rule

    #turn comma seperated string into list
    region_list =  region_list.replace(' ','').split(',')


    # Schedule Next Execution per region
    for region in region_list:
        cloudwatch_events = boto3.client('events',region_name=region)
        cron_exp = GetNextExecutionDateCron(hour_min, hour_max, repetition_days) #Get the cron expression of next run
        ScheduleNextExecution(rule_name, cron_exp,cloudwatch_events) #Edit the rule of event to trigger next run




    return {
        'statusCode': 200,
        'body': json.dumps('Successful')
    }

#Given cron exp, edit/create rule to schedule next execution
def ScheduleNextExecution(rule_name, cron_exp,cloudwatch_events):
    cloudwatch_events.put_rule(
        Name=rule_name,
        ScheduleExpression=cron_exp,
        State='ENABLED'
    )

#Randomly picks date between
#repetition_days+hour_min and repetition_days+hour_max
#in the future. Returns cron experession to do so.
def GetNextExecutionDateCron(hour_min, hour_max, repetition_days):
    hour_offset = timedelta(hours = random.uniform(int(hour_min), int(hour_max)))
    now = datetime.combine(date.today(), datetime.min.time())
    next_schedule = timedelta(days = int(repetition_days))
    future = now+next_schedule+hour_offset
    while (future.weekday() < 5):
        future = future + timedelta(days = 1)
    cronstr = future.strftime('cron(%M %H %d %m ? %Y)')
    print(cronstr)
    return cronstr
