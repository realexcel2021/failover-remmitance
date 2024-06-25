resource "aws_ssm_document" "foo" {
  name          = "FailoverRunbook"
  document_type = "Automation"
  document_format = "YAML"
  attachments_source {
    key = "S3FileUrl"
    values = ["https://${aws_s3_bucket.runbook.id}.s3.amazonaws.com/rotation.zip"]
    name = "rotation.py"
  }

  content = <<DOC
description: |-
    *Runbook for Remittance Application Failover*

    ---
    # Runbook for Remittance Application Failover

    1. Get Regions
    2. Rotate Arc Controls
    3. Failover Aurora Global Database
    4. Wait For Aurora Global Failover
    5. Update Database Secret
schemaVersion: '0.3'
assumeRole: ${module.AutomationServiceRole.iam_role_arn}
mainSteps:
  - name: GetRegions
    action: 'aws:executeScript'
    inputs:
      Runtime: python3.8
      Handler: rotation.invoke
      Script: ''
      InputPayload:
        FUNCTION: get_regions
        AWS_REGION: us-east-1
        AWS_REGION1: us-east-1
        AWS_REGION2: us-west-2
      Attachment: rotation.py
    outputs:
      - Name: ACTIVE_REGION
        Selector: $.Payload.active_region
        Type: String
      - Name: PASSIVE_REGION
        Selector: $.Payload.passive_region
        Type: String
  - name: RotateArcControls
    action: 'aws:executeScript'
    inputs:
      Runtime: python3.8
      Handler: rotation.invoke
      Script: ''
      InputPayload:
        FUNCTION: rotate_arc_controls
        AWS_REGION: '{{GetRegions.ACTIVE_REGION}}'
      Attachment: rotation.py
  - name: FailoverAuroraGlobalDatabase
    action: 'aws:executeScript'
    inputs:
      Runtime: python3.8
      Handler: rotation.invoke
      Script: ''
      InputPayload:
        FUNCTION: rotate_aurora_global_database
        AWS_REGION: '{{GetRegions.ACTIVE_REGION}}'
      Attachment: rotation.py
    outputs:
      - Name: GLOBAL_CLUSTER
        Selector: $.Payload.global_cluster
        Type: String
  - name: WaitForAuroraGlobalFailover
    action: 'aws:executeScript'
    inputs:
      Runtime: python3.8
      Handler: rotation.invoke
      Script: ''
      InputPayload:
        FUNCTION: wait_for_aurora_to_be_available
        AWS_REGION: '{{GetRegions.ACTIVE_REGION}}'
      Attachment: rotation.py
  - name: UpdateDatabaseSecret
    action: 'aws:executeScript'
    inputs:
      Runtime: python3.8
      Handler: rotation.invoke
      Script: ''
      InputPayload:
        FUNCTION: update_database_secret
        AWS_REGION: '{{GetRegions.PASSIVE_REGION}}'
      Attachment: rotation.py
files:
  rotation.py:
    checksums:
      sha256: "${data.local_file.this.content_sha256}"
DOC
}