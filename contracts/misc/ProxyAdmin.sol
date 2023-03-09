// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {TransparentUpgradeableProxy} from 'contracts/base/upgradeability/TransparentUpgradeableProxy.sol';
import {UpgradeContractPermissions} from 'contracts/misc/UpgradeContractPermissions.sol';

contract ProxyAdmin is UpgradeContractPermissions {
    TransparentUpgradeableProxy public immutable LENS_HUB_PROXY;
    address public previousImplementation;

    constructor(
        address lensHubAddress_,
        address previousImplementation_,
        address proxyAdminOwner_
    ) UpgradeContractPermissions(proxyAdminOwner_) {
        LENS_HUB_PROXY = TransparentUpgradeableProxy(payable(lensHubAddress_));
        previousImplementation = previousImplementation_;
    }

    function currentImplementation() external returns (address) {
        return LENS_HUB_PROXY.implementation();
    }

    //////////////////////////////////////////////////////
    ///             ONLY PROXY ADMIN OWNER             ///
    //////////////////////////////////////////////////////

    function rollbackLastUpgrade() external onlyOwner {
        LENS_HUB_PROXY.upgradeTo(previousImplementation);
    }

    function proxy_changeAdmin(address newAdmin) external onlyOwner {
        LENS_HUB_PROXY.changeAdmin(newAdmin);
    }

    //////////////////////////////////////////////////////
    ///   ONLY PROXY ADMIN OWNER OR UPGRADE CONTRACT   ///
    //////////////////////////////////////////////////////

    function proxy_upgrade(address newImplementation) external onlyOwnerOrUpgradeContract {
        previousImplementation = LENS_HUB_PROXY.implementation();
        LENS_HUB_PROXY.upgradeTo(newImplementation);
        delete upgradeContract;
    }

    function proxy_upgradeAndCall(address newImplementation, bytes calldata data) external onlyOwnerOrUpgradeContract {
        previousImplementation = LENS_HUB_PROXY.implementation();
        LENS_HUB_PROXY.upgradeToAndCall(newImplementation, data);
        delete upgradeContract;
    }
}
