function Create-ExternalNodeBag {
	Param
	(
		$Svc
		,
		$Name
		,
		$Description = "Test External Node Bag"
		,
		$Value = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::EntityBag.value__
		,
		[Parameter(Mandatory=$true)] $ExternalNodeId
		,
		$Tid = (Get-ApcTenant -Current).Id
	)
	
	#add parameters
	$newExternalNodeBag = New-Object biz.dfch.CS.Appclusive.Api.Core.ExternalNodeBag;
	$newExternalNodeBag.Name = $name;
	$newExternalNodeBag.Description = $description;
	$newExternalNodeBag.Value = $value;
	$newExternalNodeBag.ExternaldNodeId = $externalNodeId;
	$newExternalNodeBag.Tid = $tid;
	
	#ACT create external node bag
	$svc.Core.AddToExternalNodeBags($newExternalNodeBag);
	$result = $svc.Core.SaveChanges();
	
	#get external node bag
	$query = "Id eq {0}" -f $newExternalNodeBag.Id;
	$externalNodeBag = $svc.Core.ExternalNodeBags.AddQueryOption('$filter', $query) | select;
	
	#ASSERT external node bag
	$bin = $result.StatusCode | Should Be 201;
	$bin = $externalNodeBag | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNodeBag];
	$bin = $externalNodeBag | Should Not Be $null;
	$bin = $externalNodeBag.Name = $name;
	$bin = $externalNodeBag.Description = $description;
	$bin = $externalNodeBag.Value = $value;
	$bin = $externalNodeBag.ExternaldNodeid = $externalNodeId;
	$bin = $externalNodeBag.Tid = $tid;

	return $externalNodeBag;
}

function Update-ExternalNode{
	Param
	(
		$Svc
		,
		$externalNodeId
		,
		$UpdatedName
		,
		$UpdatedDescription
		,
		$UpdatedExternalType
		,
		$UpdatedExternalId
	)
	
	#get the external node
	$externalNode = Get-ApcExternalNode -Id $externalNodeId;
	
	#update the external node
	$externalNode.Name = $UpdatedName;
	$externalNode.Description = $UpdatedDescription;
	$externalNode.ExternalType = $UpdatedExternalType;
	$externalNode.ExternalId = $UpdatedExternalId;
	
	$svc.Core.UpdateObject($externalNode);
	$result = $svc.Core.SaveChanges();
	
	#get the updated external node
	$updatedExternalNode = Get-ApcExternalNode -Id $externalNodeId;
	
	#ASSERT - update
	$bin = $updatedExternalNode.Id | Should Be $externalNodeId;
	$bin = $updatedExternalNode.Name | Should Be $UpdatedName;
	$bin = $updatedExternalNode.Description | Should Be $UpdatedDescription;
	$bin = $updatedExternalNode.ExternalType | Should Be $UpdatedExternalType;
	$bin = $updatedExternalNode.ExternalId | Should Be $UpdatedExternalId;
	
	return $updatedExternalNode;
}

function Update-ExternalNodeBag{
	Param
	(
		$Svc
		,
		$ExternalNodeBagId
		,
		$UpdatedName
		,
		$UpdatedDescription
		,
		$UpdatedValue
	)
	
	#get the external node bag
	$filter = "Id eq {0}" -f $externalNodeBagId;
	$externalNodeBag = $svc.Core.ExternalNodeBags.AddQueryOption('$filter', $filter) | Select;
	
	#update the external node bag
	$externalNodeBag.Name = $UpdatedName;
	$externalNodeBag.Description = $UpdatedDescription;
	$externalNodeBag.Value = $UpdatedValue;
	
	$svc.Core.UpdateObject($externalNodeBag);
	$result = $svc.Core.SaveChanges();
	
	#get the updated external node
	$updatedExternalNodeBag = $svc.Core.ExternalNodeBags.AddQueryOption('$filter', $filter) | Select;
	
	#ASSERT - update
	$bin = $updatedExternalNodeBag.Id | Should Be $ExternalNodeBagId;
	$bin = $updatedExternalNodeBag.Name | Should Be $UpdatedName;
	$bin = $updatedExternalNodeBag.Description | Should Be $UpdatedDescription;
	$bin = $updatedExternalNodeBag.Value | Should Be $UpdatedValue;
	
	return $updatedExternalNodeBag;
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




