$vm_list = get-content CreateSnapshot_for_MSL.ini
$old_change = (get-content CreateSnapshot_for_MSL.ini -totalcount 1)
$new_change = (get-content CreateSnapshot_for_MSL.ini -totalcount 2)[-1]
$vcip1 = (get-content CreateSnapshot_for_MSL.ini -totalcount 3)[-1]
$vcip2 = (get-content CreateSnapshot_for_MSL.ini -totalcount 4)[-1]
$start_line = (get-content CreateSnapshot_for_MSL.ini -totalcount 5)[-1]
function login
{
	if (connect-viserver -server "$vcip1","$vcip2")
	{
		for ($i = [int]$start_line; $i -le ($vm_list.count)-1; $i++)
		{
			$vm = $vm_list[$i]
			if (get-vm $vm)
			{
				if (get-vm $vm |get-snapshot -name $old_change)
				{
					get-vm $vm |get-snapshot -name $old_change | remove-snapshot -confirm:$false
					while ("get-vm $vm |get-snapshot -name $old_change" -ne 1)
					{
						get-vm $vm |new-snapshot -name $new_change
						"$vm : $old_change deleted $new_change created.">> record.log
						break
					}
				}
				else
				{
					if (get-vm $vm |get-snapshot -name $new_change)
					{
					}
					else
					{
						get-vm $vm |new-snapshot -name $new_change
						"$vm : $new_change created.">> record.log
					}
				}
			}
			else
			{
				$vm = "$vm.msl.cn"
				if (get-vm $vm)
				{
					if (get-vm $vm |get-snapshot -name $old_change)
					{
						get-vm $vm |get-snapshot -name $old_change | remove-snapshot -confirm:$false
						while ("get-vm $vm |get-snapshot -name $old_change" -ne 1)
						{
							get-vm $vm |new-snapshot -name $new_change
							"$vm : $old_change deleted $new_change created.">> record.log
							break
						}
					}
					else
					{
						if (get-vm $vm |get-snapshot -name $new_change)
						{
						}
						else
						{
							get-vm $vm |new-snapshot -name $new_change
							"$vm : $new_change created.">> record.log
						}
					}
				}
				else
				{
					write-warning -message "$vm Not found"
					"$vm : Not found. Please check.">> record.log
				}
			}
		}
	}
	else
	{
		$choice = read-host "Failed to login $vcip1, $vcip2.`nDo you want to try it again? (y/n)"
		if ($choice -match "y")
		{
			login
		}
		else
		{
			"Any key to exit"
			read-host | out-null
		}
	}
}
login
#created by Alpha Zhu