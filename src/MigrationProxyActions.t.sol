pragma solidity 0.5.11;

import "ds-token/token.sol";

import { DssDeployTestBase } from "dss-deploy/DssDeploy.t.base.sol";
import { AuthGemJoin } from "dss-deploy/join.sol";

import { SaiDaiMigration } from "./SaiDaiMigration.sol";
import { SaiDaiMigrationTest } from "./SaiDaiMigration.t.sol";
import { MigrationProxyActions } from "./MigrationProxyActions.sol";

contract ScdMcdMigrationTest is SaiDaiMigrationTest {
    MigrationProxyActions proxyActions;

    function setUp() public {
        super.setUp();

        // Create proxy actions
        proxyActions = new MigrationProxyActions();
    }

    function _swapSaiToDai(uint amount) internal {
        sai.approve(address(proxyActions), amount);
        proxyActions.swapSaiToDai(address(migration), amount);
    }

    function testProxySwapSaiToDai() public {
        assertEq(sai.balanceOf(address(this)), 10000000 ether);
        assertEq(dai.balanceOf(address(this)), 0);
        _swapSaiToDai(10000000 ether);
        assertEq(sai.balanceOf(address(this)), 0 ether);
        assertEq(dai.balanceOf(address(this)), 10000000 ether);
        (uint ink, uint art) = vat.urns("SAI", address(migration));
        assertEq(ink, 10000000 ether);
        assertEq(art, 10000000 ether);
    }

    function testProxySwapDaiToSai() public {
        _swapSaiToDai(10000000 ether);
        dai.approve(address(proxyActions), 6000000 ether);
        proxyActions.swapDaiToSai(address(migration), 6000000 ether);
        assertEq(sai.balanceOf(address(this)), 6000000 ether);
        assertEq(dai.balanceOf(address(this)), 4000000 ether);
        (uint ink, uint art) = vat.urns("SAI", address(migration));
        assertEq(ink, 4000000 ether);
        assertEq(art, 4000000 ether);
    }

}
