// +build ignore

package main

import (
	"encoding/json"
	"io/ioutil"
	"log"
	"math"
	"os"
	"text/template"
)

type InstanceType struct {
	ID            string  `json:"id"`
	Name          string  `json:"name"`
	VCPUs         int     `json:"vcpus"`
	ECU           float64 `json:"ecu"`
	HasAVX        bool    `json:"avx"`
	HasAVX2       bool    `json:"avx2"`
	HasIntelTurbo bool    `json:"intel_turbo"`
}

func LoadInstanceTypes(filename string) ([]InstanceType, error) {
	data, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, err
	}
	var instances []InstanceType
	if err := json.Unmarshal(data, &instances); err != nil {
		return nil, err
	}
	return instances, nil
}

type LaunchSpecification struct {
	InstanceType     string
	WeightedCapacity int
}

type Parameters struct {
	LaunchSpecifications []LaunchSpecification
}

var tmpl = `resource "aws_spot_fleet_request" "workers" {
	count                               = "${length(var.targets)}"
	iam_fleet_role                      = "${aws_iam_role.fleet_role.arn}"
	replace_unhealthy_instances         = true
	wait_for_fulfillment                = true
	target_capacity                     = "${var.workers_target_ecu}"
	allocation_strategy                 = "lowestPrice"
	fleet_type                          = "maintain"
	terminate_instances_with_expiration = true
  
{{range .LaunchSpecifications}}
	launch_specification {
	  ami               = "${data.aws_ami.bionic.image_id}"
	  instance_type     = "{{.InstanceType}}"
	  weighted_capacity = {{.WeightedCapacity}}
	  key_name          = "${aws_key_pair.access.key_name}"
  
	  vpc_security_group_ids = [
		"${aws_security_group.allow_ssh.id}",
		"${aws_security_group.egress_all.id}",
		"${aws_security_group.worker.id}",
	  ]
  
	  user_data            = "${element(data.template_file.worker_init.*.rendered, count.index)}"
	  iam_instance_profile = "${aws_iam_instance_profile.prod_profile.id}"
  
	  tags = {
		Name = "${var.targets[count.index]}-worker"
	  }
	}
{{end}}

	depends_on = ["aws_iam_role_policy_attachment.fleet-tagging-role-policy-attachment"]
}
`

func main() {
	instances, err := LoadInstanceTypes("instance_types.json")
	if err != nil {
		log.Fatal(err)
	}

	params := Parameters{}
	for _, i := range instances {
		if i.VCPUs > 4 {
			continue
		}
		if !(i.ID[0] == 'c' || i.ID[0] == 'm') {
			continue
		}
		if !(i.HasAVX && i.HasAVX2 && i.HasIntelTurbo) {
			continue
		}

		capacity := int(math.Floor(i.ECU))
		if capacity == 0 {
			continue
		}

		spec := LaunchSpecification{
			InstanceType:     i.ID,
			WeightedCapacity: capacity,
		}
		log.Print(spec)

		params.LaunchSpecifications = append(params.LaunchSpecifications, spec)
	}

	t := template.Must(template.New("fleet").Parse(tmpl))
	if err := t.Execute(os.Stdout, params); err != nil {
		log.Fatal(err)
	}
}
