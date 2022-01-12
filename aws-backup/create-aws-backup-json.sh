#!/bin/bash

profile="default"
region="us-east-1"

get_account_id () {
	id=$(aws sts get-caller-identity --query Account --output text)
}

create_vault () {
	aws backup create-backup-vault --backup-vault-name efs-vault --profile $profile --region $region
}

create_backup_plans () {
	aws backup create-backup-plan \
		--profile $profile \
		--region $region \
		--cli-input-json file://efs-0000-backup.json

	aws backup create-backup-plan \
		--profile $profile \
		--region $region \
		--cli-input-json file://efs-0400-backup.json
	
	aws backup create-backup-plan \
		--profile $profile \
		--region $region \
		--cli-input-json file://efs-0800-backup.json

	aws backup create-backup-plan \
		--profile $profile \
		--region $region \
		--cli-input-json file://efs-1200-backup.json

	aws backup create-backup-plan \
		--profile $profile \
		--region $region \
		--cli-input-json file://efs-1600-backup.json

	aws backup create-backup-plan \
		--profile $profile \
		--region $region \
		--cli-input-json file://efs-2000-backup.json

}

get_plan_ids () {
	plan1=$(aws backup list-backup-plans --query "BackupPlansList[?BackupPlanName=='efs-0000'].BackupPlanId" --profile $profile --region $region --output text)
	plan2=$(aws backup list-backup-plans --query "BackupPlansList[?BackupPlanName=='efs-0400'].BackupPlanId" --profile $profile --region $region --output text)
	plan3=$(aws backup list-backup-plans --query "BackupPlansList[?BackupPlanName=='efs-0800'].BackupPlanId" --profile $profile --region $region --output text)
	plan4=$(aws backup list-backup-plans --query "BackupPlansList[?BackupPlanName=='efs-1200'].BackupPlanId" --profile $profile --region $region --output text)
	plan5=$(aws backup list-backup-plans --query "BackupPlansList[?BackupPlanName=='efs-1600'].BackupPlanId" --profile $profile --region $region --output text)
	plan6=$(aws backup list-backup-plans --query "BackupPlansList[?BackupPlanName=='efs-2000'].BackupPlanId" --profile $profile --region $region --output text)
}

create_backup_selections () {

	aws backup create-backup-selection \
		--backup-plan-id $plan1 \
                --profile $profile \
                --region $region \
		--cli-input-json file://efs-0000-selection.json

	aws backup create-backup-selection \
		--backup-plan-id $plan2 \
		--profile $profile \
                --region $region \
		--cli-input-json file://efs-0400-selection.json

	aws backup create-backup-selection \
		--backup-plan-id $plan3 \
                --profile $profile \
                --region $region \
		--cli-input-json file://efs-0800-selection.json

	aws backup create-backup-selection \
		--backup-plan-id $plan4 \
                --profile $profile \
                --region $region \
		--cli-input-json file://efs-1200-selection.json

	aws backup create-backup-selection \
		--backup-plan-id $plan5 \
                --profile $profile \
                --region $region \
		--cli-input-json file://efs-1600-selection.json

	aws backup create-backup-selection \
		--backup-plan-id $plan6 \
		--profile $profile \
		--region $region \
		--cli-input-json file://efs-2000-selection.json
}

get_account_id
create_vault

h=0
for i in {0000,0400,0800,1200,1600,2000}
do
cat << EOF > efs-$i-backup.json
{
    "BackupPlan":{
        "BackupPlanName":"efs-$i",
        "Rules":[
            {
                "RuleName":"efs-$i",
                "ScheduleExpression":"cron(0 $h ? * * *)",
                "StartWindowMinutes":60,
                "TargetBackupVaultName":"efs-vault",
                "Lifecycle":{
                    "DeleteAfterDays":7
                }
            }
        ]
    }
}
EOF
h=$(($h+4))
done

create_backup_plans
get_plan_ids

for i in {0000,0400,0800,1200,1600,2000}
do
cat << EOF > efs-$i-selection.json
{
    "BackupSelection":{
        "SelectionName": "efs-$i",
        "IamRoleArn": "arn:aws:iam::$id:role/service-role/AWSBackupDefaultServiceRole",
        "Resources": [],
        "ListOfTags": [
            {
                "ConditionType": "STRINGEQUALS",
                "ConditionKey": "aws-backup",
                "ConditionValue": "efs-$i"
            }
        ]
    }
}
EOF
done

create_backup_selections

sleep 5
rm -f *.json
