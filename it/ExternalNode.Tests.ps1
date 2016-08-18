#includes tests for CLOUDTCL-

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe -Tags "ExternalNode.Tests" "ExternalNode.Tests" {
	. "$here\$sut"
	
	$entityPrefix = "TestItem-";
	$usedEntitySets = @("Nodes", "ExternalNodes");
	$nodeEntityKindId = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Node.value__;
	$nodeParentId = (Get-ApcTenant -Current).NodeId;
	
	Context "#CLOUDTCL--ExternalNodeTests" {
		
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			$svc = Enter-Appclusive;
		}
		
		AfterEach {
            $svc = Enter-Appclusive;
            $entityFilter = "startswith(Name, '{0}')" -f $entityPrefix;

            foreach ($entitySet in $usedEntitySets)
            {
                $entities = $svc.Core.$entitySet.AddQueryOption('$filter', $entityFilter) | Select;
         
                foreach ($entity in $entities)
                {
                    Remove-ApcEntity -svc $svc -Id $entity.Id -EntitySetName $entitySet -Confirm:$false;
                }
            }
        }
		
        It "Create-Get-ExternalNode" -Test {            
            $nodeName = $entityPrefix + "node";
			$extName = $entityPrefix + "externalnode";
			
			#ACT create node
			$newNode = New-ApcNode -Name $nodeName -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#get Id of the node
			$nodeId = $newNode.Id;
			
			#create external node
			$extNode = New-ApcExternalNode -name $extName -NodeId $nodeId -ExternalId $nodeId -ExternalType "ArbitraryType" -svc $svc | select;
			
			#get id of external node
			$extNodeId = $extNode.Id;
			
			#ASSERT external Node
			$extNode | Should Not Be $null;
            $extNode | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNode];
            $extNode.NodeId | Should Be $nodeId;
            $extNode.ExternalId | Should Be $nodeId;
            $extNode.ExternalType | Should Be "ArbitraryType";
            $extNode.Name | Should Be $extName;
			
			#ACT Get the external-node using Get-ApcExternalNode
			$loadedextNode = Get-ApcExternalNode -Id $extNodeId -svc $svc;
			
			#ASSERT the node we get is the same
			$loadedextNode | Should Not Be $null;
            $loadedextNode | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNode];
            $loadedextNode.NodeId | Should Be $nodeId;
            $loadedextNode.ExternalId | Should Be $nodeId;
            $loadedextNode.ExternalType | Should Be "ArbitraryType";
            $loadedextNode.Name | Should Be $extName;
			
			#CLEANUP delete Node - external node is deleted automatically
			Remove-ApcNode -svc $svc -Id $nodeId -Confirm:$false;
        }
		
        It "Create-Get-ExternalNodeBags" -Test {
            $nodeName = $entityPrefix + "node";
			$extName = $entityPrefix + "externalnode";
			
			#ACT create node
			$newNode = New-ApcNode -Name $nodeName -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#get Id of the node
			$nodeId = $newNode.Id;
			$nodeEntityKindId = $newNode.EntityKindId;
			
			#create external node
			$extNode = New-ApcExternalNode -name $extName -NodeId $nodeId -ExternalId $nodeId -ExternalType "ArbitraryType" -svc $svc | select;
			Write-Host ($extNode | out-string);
			#get id of external node
			$extNodeId = $extNode.Id;
			
			#ASSERT external Node
			$extNode | Should Not Be $null;
            $extNode | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNode];
            $extNode.NodeId | Should Be $nodeId;
            $extNode.ExternalId | Should Be $nodeId;
            $extNode.ExternalType | Should Be "ArbitraryType";
            $extNode.Name | Should Be $extName;

            $countOfBags = 20;
			
            for($i = 1; $i -le $countOfBags; $i++)
            {
                $nodeBagName = ("{0}-Name-{1}" -f $nodeName,$i);
                $nodeBagValue = ("{0}-Value-{1}" -f $nodeName,$i);

                $nodeBag = Create-ExternalNodeBag -Name $nodeBagName -ExternalNodeId $extNodeId -Value $nodeBagValue -Svc $svc;
            }
			
			#get the external node bags with specific id
            $nodeBagsFilter = "ExternaldNodeId eq {0}" -f $extNodeId;
            $createdNodeBags = $svc.Core.ExternalNodeBags.AddQueryOption('$filter', $nodeBagsFilter) | Select;
			
			#ASSERT  count of external node bags
            $createdNodeBags.Count | Should Be $countOfBags;
			
			
            
        }
        <#
        It "Update-ExternalNode" -Test {                    
            $nodeName = "Update-ExternalNode";
            $nodeId = 1;
            $node = CreateExternalNode $nodeId $nodeName;

            $svc.Core.AddToExternalNodes($node);
            $svc.Core.SaveChanges();

            $nodeFilter = ("Name eq '{0}'" -f $nodeName);
            $createdNode = $svc.Core.ExternalNodes.AddQueryOption('$filter', $nodeFilter).AddQueryOption('$top', 1) | Select;

            $createdNode | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNode];
            $createdNode.NodeId | Should Be 1;
            $createdNode.ExternalId | Should Be ("Arbitrary-Id-{0}" -f $nodeId);
            $createdNode.ExternalType | Should Be "Arbitrary-Type";
            $createdNode.Name | Should Be $nodeName;
            
            $createdNode.ExternalId = ("Arbitrary-Id-{0}-Updated" -f $nodeId);
            $createdNode.ExternalType = "Arbitrary-Type-Updated";
            $createdNode.Name = ("{0}-Updated" -f $nodeName);

            $svc.Core.UpdateObject($createdNode);
            $svc.Core.SaveChanges();
            
            $nodeFilter = ("Name eq '{0}-Updated'" -f $nodeName);
            $updatedNode = $svc.Core.ExternalNodes.AddQueryOption('$filter', $nodeFilter).AddQueryOption('$top', 1) | Select;
            
            $updatedNode | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNode];
            $updatedNode.NodeId | Should Be 1;
            $updatedNode.ExternalId | Should Be ("Arbitrary-Id-{0}-Updated" -f $nodeId);
            $updatedNode.ExternalType | Should Be "Arbitrary-Type-Updated";
            $updatedNode.Name | Should Be ("{0}-Updated" -f $nodeName);
        }

        It "Update-ExternalNodeBags" -Test {
            $nodeName = "Update-ExternalNodeBags";
            $nodeId = 1;
            $node = CreateExternalNode $nodeId $nodeName;

            $countOfBags = 20;

            $svc.Core.AddToExternalNodes($node);
            $svc.Core.SaveChanges();

            $nodeFilter = ("Name eq '{0}'" -f $nodeName);
            $createdNode = $svc.Core.ExternalNodes.AddQueryOption('$filter', $nodeFilter).AddQueryOption('$top', 1) | Select;

            for($i = 1; $i -le $countOfBags; $i++)
            {
                $nodeBagName = ("{0}-Name-{1}" -f $nodeName,$i);
                $nodeBagValue = ("{0}-Value-{1}" -f $nodeName,$i);

                $nodebag = CreateExternalNodeBag $createdNode.Id $nodeBagName $nodeBagValue;
                
                $svc.Core.AddToExternalNodeBags($nodebag);
                $svc.Core.SaveChanges();
            }

            $nodeBagsFilter = "ExternaldNodeId eq {0}" -f $createdNode.Id;
            $createdNodeBags = $svc.Core.ExternalNodeBags.AddQueryOption('$filter', $nodeBagsFilter) | Select;

            $createdNodeBags.Count | Should Be $countOfBags;
            for($i = 1; $i -le $countOfBags; $i++)
            {
                $nodeBagName = ("{0}-Name-{1}" -f $nodeName,$i);
                $nodeBagValue = ("{0}-Value-{1}" -f $nodeName,$i);
                
                $nodeBagsFilter = "Name eq '{0}'" -f $nodeBagName;
                $createdNodeBag = $svc.Core.ExternalNodeBags.AddQueryOption('$filter', $nodeBagsFilter) | Select;

                $createdNodeBag | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNodeBag];
                $createdNodeBag.Name | Should Be $nodeBagName;
                $createdNodeBag.Value | Should Be $nodeBagValue;
                $createdNodeBag.ExternaldNodeId | Should Be $createdNode.Id;

                $createdNodeBag.Name = ("{0}-Updated" -f $nodeBagName);
                $createdNodeBag.Value = ("{0}-Updated" -f $nodeBagValue);
                $svc.Core.UpdateObject($createdNodeBag);
            }

            $svc.Core.SaveChanges();
            for($i = 1; $i -le $countOfBags; $i++)
            {
                $nodeBagName = ("{0}-Name-{1}-Updated" -f $nodeName,$i);
                $nodeBagValue = ("{0}-Value-{1}-Updated" -f $nodeName,$i);
                
                $nodeBagsFilter = "Name eq '{0}'" -f $nodeBagName;
                $createdNodeBag = $svc.Core.ExternalNodeBags.AddQueryOption('$filter', $nodeBagsFilter) | Select;

                $createdNodeBag | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNodeBag];
                $createdNodeBag.Name | Should Be $nodeBagName;
                $createdNodeBag.Value | Should Be $nodeBagValue;
                $createdNodeBag.ExternaldNodeId | Should Be $createdNode.Id;
            }
        }
        
        It "Delete-ExternalNode" -Test {
                    
            $nodeName = "Delete-ExternalNode";
            $nodeId = 1;
            $node = CreateExternalNode $nodeId $nodeName;

            $svc.Core.AddToExternalNodes($node);
            $svc.Core.SaveChanges();

            $nodeFilter = ("Name eq '{0}'" -f $nodeName);
            $createdNode = $svc.Core.ExternalNodes.AddQueryOption('$filter', $nodeFilter).AddQueryOption('$top', 1) | Select;

            $createdNode | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNode];
            $createdNode.NodeId | Should Be 1;
            $createdNode.ExternalId | Should Be ("Arbitrary-Id-{0}" -f $nodeId);
            $createdNode.ExternalType | Should Be "Arbitrary-Type";
            $createdNode.Name | Should Be $nodeName;

            $svc.Core.DeleteObject($createdNode);
            $svc.Core.SaveChanges();

            $nodeFilter = ("Name eq '{0}'" -f $nodeName);
            $deletedNode = $svc.Core.ExternalNodes.AddQueryOption('$filter', $nodeFilter).AddQueryOption('$top', 1) | Select;

            $deletedNode | Should Be $null;
        }
	
        It "Delete-ExternalNode-Also-Deletes-NodeBags" -Test {
            $nodeName = "Delete-ExternalNode-Also-Deletes-NodeBags";
            $nodeId = 1;
            $node = CreateExternalNode $nodeId $nodeName;

            $countOfBags = 20;

            $svc.Core.AddToExternalNodes($node);
            $svc.Core.SaveChanges();

            $nodeFilter = ("Name eq '{0}'" -f $nodeName);
            $createdNode = $svc.Core.ExternalNodes.AddQueryOption('$filter', $nodeFilter).AddQueryOption('$top', 1) | Select;

            for($i = 1; $i -le $countOfBags; $i++)
            {
                $nodeBagName = ("{0}-Name-{1}" -f $nodeName,$i);
                $nodeBagValue = ("{0}-Value-{1}" -f $nodeName,$i);

                $nodebag = CreateExternalNodeBag $createdNode.Id $nodeBagName $nodeBagValue;
                
                $svc.Core.AddToExternalNodeBags($nodebag);
                $svc.Core.SaveChanges();
            }

            $svc.Core.DeleteObject($createdNode);
            $svc.Core.SaveChanges();
            
            $nodeBagsFilter = "ExternaldNodeId eq {0}" -f $createdNode.Id;
            $createdNodeBags = $svc.Core.ExternalNodeBags.AddQueryOption('$filter', $nodeBagsFilter) | Select;

            $createdNodeBags.Count | Should Be 0;
        }#>
    }
}

#
# Copyright 2016 d-fens GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
