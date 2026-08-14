locals {
  efs_volumes = [
    {
      host_path = null
      name      = "${local.app_name}-${var.sub_env}-efs"

      efs_volume_configuration = [
        {
          file_system_id          = data.aws_ssm_parameter.efs_id.value
          root_directory          = "/"
          transit_encryption      = "ENABLED"
          transit_encryption_port = "2049"

          authorization_config = [
            {
              access_point_id = data.aws_ssm_parameter.efs_ap_id.value
              iam             = "DISABLED"
            }
          ]
        }
      ]
    }
  ]

  mount_points = [
    {
      sourceVolume  = "${local.app_name}-${var.sub_env}-efs"
      containerPath = "/mnt/efs/SearchIndex"
      readOnly      = false
    }
  ]
}
