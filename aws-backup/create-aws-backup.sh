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
		--backup-plan "{\"BackupPlanName\":\"efs-0000\",\"Rules\":[{\"RuleName\":\"efs-0000\",\"ScheduleExpression\":\"cron(0 4 ? * * *)\",\"StartWindowMinutes\":60,\"TargetBackupVaultName\":\"efs-vault\",\"Lifecycle\":{\"DeleteAfterDays\":7}}]}"
	aws backup create-backup-plan \
		--profile $profile \
		--region $region \
		--backup-plan "{\"BackupPlanName\":\"efs-0400\",\"Rules\":[{\"RuleName\":\"efs-0400\",\"ScheduleExpression\":\"cron(0 4 ? * * *)\",\"StartWindowMinutes\":60,\"TargetBackupVaultName\":\"efs-vault\",\"Lifecycle\":{\"DeleteAfterDays\":7}}]}"
	aws backup create-backup-plan \
		--profile $profile \
		--region $region \
		--backup-plan "{\"BackupPlanName\":\"efs-0800\",\"Rules\":[{\"RuleName\":\"efs-0800\",\"ScheduleExpression\":\"cron(0 8 ? * * *)\",\"StartWindowMinutes\":60,\"TargetBackupVaultName\":\"efs-vault\",\"Lifecycle\":{\"DeleteAfterDays\":7}}]}"
	aws backup create-backup-plan \
		--profile $profile \
		--region $region \
		--backup-plan "{\"BackupPlanName\":\"efs-1200\",\"Rules\":[{\"RuleName\":\"efs-1200\",\"ScheduleExpression\":\"cron(0 12 ? * * *)\",\"StartWindowMinutes\":60,\"TargetBackupVaultName\":\"efs-vault\",\"Lifecycle\":{\"DeleteAfterDays\":7}}]}"
	aws backup create-backup-plan \
		--profile $profile \
		--region $region \
		--backup-plan "{\"BackupPlanName\":\"efs-1600\",\"Rules\":[{\"RuleName\":\"efs-1600\",\"ScheduleExpression\":\"cron(0 16 ? * * *)\",\"StartWindowMinutes\":60,\"TargetBackupVaultName\":\"efs-vault\",\"Lifecycle\":{\"DeleteAfterDays\":7}}]}"
	aws backup create-backup-plan \
		--profile $profile \
		--region $region \
		--backup-plan "{\"BackupPlanName\":\"efs-2000\",\"Rules\":[{\"RuleName\":\"efs-2000\",\"ScheduleExpression\":\"cron(0 20 ? * * *)\",\"StartWindowMinutes\":60,\"TargetBackupVaultName\":\"efs-vault\",\"Lifecycle\":{\"DeleteAfterDays\":7}}]}"
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
		--cli-input-json "{\"BackupSelection\":{\"SelectionName\":\"efs-0000\",\"IamRoleArn\":\"arn:aws:iam::$id:role/service-role/AWSBackupDefaultServiceRole\",\"Resources\":[],\"ListOfTags\":[{\"ConditionType\":\"STRINGEQUALS\",\"ConditionKey\":\"aws-backup\",\"ConditionValue\":\"efs-0000\"}]}}" \
		--profile $profile \
		--region $region
	aws backup create-backup-selection \
		--backup-plan-id $plan2 \
		--cli-input-json "{\"BackupSelection\":{\"SelectionName\":\"efs-0400\",\"IamRoleArn\":\"arn:aws:iam::$id:role/service-role/AWSBackupDefaultServiceRole\",\"Resources\":[],\"ListOfTags\":[{\"ConditionType\":\"STRINGEQUALS\",\"ConditionKey\":\"aws-backup\",\"ConditionValue\":\"efs-0400\"}]}}" \
		--profile $profile \
		--region $region
	aws backup create-backup-selection \
		--backup-plan-id $plan3 \
		--cli-input-json "{\"BackupSelection\":{\"SelectionName\":\"efs-0800\",\"IamRoleArn\":\"arn:aws:iam::$id:role/service-role/AWSBackupDefaultServiceRole\",\"Resources\":[],\"ListOfTags\":[{\"ConditionType\":\"STRINGEQUALS\",\"ConditionKey\":\"aws-backup\",\"ConditionValue\":\"efs-0800\"}]}}" \
		--profile $profile \
		--region $region
	aws backup create-backup-selection \
		--backup-plan-id $plan4 \
		--cli-input-json "{\"BackupSelection\":{\"SelectionName\":\"efs-1200\",\"IamRoleArn\":\"arn:aws:iam::$id:role/service-role/AWSBackupDefaultServiceRole\",\"Resources\":[],\"ListOfTags\":[{\"ConditionType\":\"STRINGEQUALS\",\"ConditionKey\":\"aws-backup\",\"ConditionValue\":\"efs-1200\"}]}}" \
		--profile $profile \
		--region $region
	aws backup create-backup-selection \
		--backup-plan-id $plan5 \
		--cli-input-json "{\"BackupSelection\":{\"SelectionName\":\"efs-1600\",\"IamRoleArn\":\"arn:aws:iam::$id:role/service-role/AWSBackupDefaultServiceRole\",\"Resources\":[],\"ListOfTags\":[{\"ConditionType\":\"STRINGEQUALS\",\"ConditionKey\":\"aws-backup\",\"ConditionValue\":\"efs-1600\"}]}}" \
		--profile $profile \
		--region $region
	aws backup create-backup-selection \
		--backup-plan-id $plan6 \
		--cli-input-json "{\"BackupSelection\":{\"SelectionName\":\"efs-2000\",\"IamRoleArn\":\"arn:aws:iam::$id:role/service-role/AWSBackupDefaultServiceRole\",\"Resources\":[],\"ListOfTags\":[{\"ConditionType\":\"STRINGEQUALS\",\"ConditionKey\":\"aws-backup\",\"ConditionValue\":\"efs-2000\"}]}}" \
		--profile $profile \
		--region $region
}

get_account_id
create_vault
create_backup_plans
get_plan_ids
create_backup_selections
