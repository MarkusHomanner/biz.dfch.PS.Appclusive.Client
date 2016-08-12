
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Push-ChangeTracker" -Tags "Push-ChangeTracker" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Get-ModuleVariable.ps1"
	. "$here\Format-ResultAs.ps1"
	
	Context "Push-ChangeTracker" {
	
		# Context wide constants
		$biz_dfch_PS_Appclusive_Client = @{ };
		Mock Get-ModuleVariable { return $biz_dfch_PS_Appclusive_Client; }
		
		
		BeforeEach {
			Remove-Module biz.dfch.PS.Appclusive.Client -ErrorAction:SilentlyContinue;
			Import-Module biz.dfch.PS.Appclusive.Client -ErrorAction:SilentlyContinue;
			
			$biz_dfch_PS_Appclusive_Client.DataContext = New-Object System.Collections.Stack;
		}
		
		It "Warmup" -Test {
			$true | Should Be $true;
		}
		
		It "Push-ChangeTrackerUninitialised-ThrowsException" -Test {
			# Arrange
			$svc = Enter-ApcServer;

			{ $result = Push-ChangeTracker -svc $null -ListAvailable; } | Should Throw 'Precondition failed';
			{ $result = Push-ChangeTracker -svc $null -ListAvailable; } | Should Throw 'Connect to the server before using the Cmdlet';
		}

		It "Push-ChangeTrackerReinitialised-HasEmptyDataContext" -Test {
			# Arrange
			$svc = Enter-ApcServer;

			# Act and Assert
			Assert-MockCalled Get-ModuleVariable;
			$biz_dfch_PS_Appclusive_Client.ContainsKey('DataContext') | Should Be $true;
			$biz_dfch_PS_Appclusive_Client.DataContext.Count | Should Be 0;
		}

		It "Push-ChangeTrackerListAvailableWithZeroEntities-ReturnsHashtableWithZeroEntries" -Test {
			# Arrange
			$svc = Enter-ApcServer;
			
			# Act
			$result = Push-ChangeTracker -svc $svc -ListAvailable;

			# Assert
			$result -is [hashtable] | Should Be $true;
			$result.ContainsKey('Entities') | Should Be $true;
			$result.Entities.Count | Should Be 0;
			$result.ContainsKey('Links') | Should Be $true;
			$result.Links.Count | Should Be 0;
			Assert-MockCalled Get-ModuleVariable;
			$biz_dfch_PS_Appclusive_Client.ContainsKey('DataContext') | Should Be $true;
			$biz_dfch_PS_Appclusive_Client.DataContext.Count | Should Be 0;
		}

		It "Push-ChangeTrackerListAvailableWithTwoEntities-ReturnsHashtableWithTwoEntries" -Test {
			# Arrange
			$count = 2;
			$svc = Enter-ApcServer;
			$endpoints = $svc.Diagnostics.Endpoints | Select -First $count;
			
			# Act
			$result = Push-ChangeTracker -svc $svc -Service Diagnostics -ListAvailable;

			# Assert
			$result -is [hashtable] | Should Be $true;
			$result.ContainsKey('Entities') | Should Be $true;
			$result.Entities.Count | Should Be 2;
			$result.ContainsKey('Links') | Should Be $true;
			$result.Links.Count | Should Be 0;
			Assert-MockCalled Get-ModuleVariable;
			$biz_dfch_PS_Appclusive_Client.ContainsKey('DataContext') | Should Be $true;
			$biz_dfch_PS_Appclusive_Client.DataContext.Count | Should Be 0;
		}
		
		It "Push-ChangeTrackerWithTwoEntities-ReturnsHashtableWithTwoEntries" -Test {
			# Arrange
			$count = 2;
			$svc = Enter-ApcServer;
			$endpoints = $svc.Diagnostics.Endpoints | Select -First $count;
			
			# Act
			$result = Push-ChangeTracker -svc $svc -Service Diagnostics;

			# Assert
			Assert-MockCalled Get-ModuleVariable;
			$biz_dfch_PS_Appclusive_Client.ContainsKey('DataContext') | Should Be $true;
			$biz_dfch_PS_Appclusive_Client.DataContext.Count | Should Be 1;
		}

		It "Push-ChangeTrackerTwoTimes-ReturnsStackSizeTwo" -Test {
			# Arrange
			$count = 2;
			$svc = Enter-ApcServer;
			$endpoints = $svc.Diagnostics.Endpoints | Select -First $count;
			
			# Act
			$result = Push-ChangeTracker -svc $svc -Service Diagnostics;
			$result = Push-ChangeTracker -svc $svc -Service Diagnostics;

			# Assert
			Assert-MockCalled Get-ModuleVariable;
			$biz_dfch_PS_Appclusive_Client.ContainsKey('DataContext') | Should Be $true;
			$biz_dfch_PS_Appclusive_Client.DataContext.Count | Should Be 2;
		}
	}
}

#
# Copyright 2015 d-fens GmbH
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
