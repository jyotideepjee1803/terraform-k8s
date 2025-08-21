output "master_public_ips" {
  value = [for i in aws_instance.master : i.public_ip]
} 

output "worker_public_ips" {
  value =  [for i in aws_instance.worker : i.public_ip]

}
