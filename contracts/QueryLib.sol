// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ProductLib.sol";

library QueryLib {
    uint256 constant SECONDS_IN_DAY = 86400;


    /**
    * @dev Calculates the average price of all non-expired products.
    * @param products The mapping of all products.
    * @param tokenCounter The total number of products.
    * @return The average price of all non-expired products.
    */
    function calculateAveragePrice(mapping(uint256 => ProductLib.Product) storage products, uint256 tokenCounter) internal view returns (uint256) {
        require(tokenCounter > 0, "No products available for analysis.");

        uint256 totalPrice = 0;
        uint256 nonExpiredProductCount = 0;

        for (uint256 i = 0; i < tokenCounter; i++) {
            if (block.timestamp < products[i].expiryDate) {
                totalPrice += products[i].price;
                nonExpiredProductCount++;
            }
        }

        require(nonExpiredProductCount > 0, "No valid products available for analysis.");
        return totalPrice / nonExpiredProductCount;
    }

    /**
    * @dev Gets all products expiring within a given threshold.
    * @param products The mapping of all products. 
    * @param tokenCounter The total number of products.
    * @param expiryThresholdInDays The number of days within which the products should expire.
    * @return An array of IDs of the expiring products.
    */
    function getExpiringProducts(mapping(uint256 => ProductLib.Product) storage products, uint256 tokenCounter, uint256 expiryThresholdInDays) internal view returns (uint256[] memory) {
        require(expiryThresholdInDays > 0, "Threshold must be positive");

        uint256[] memory expiringProductIds = new uint256[](tokenCounter);
        uint256 nonExpiredProductCount = 0;

        for (uint256 i = 0; i < tokenCounter; i++) {
            uint256 daysUntilExpiry = (products[i].expiryDate - block.timestamp) / SECONDS_IN_DAY;
            if (daysUntilExpiry <= expiryThresholdInDays && block.timestamp < products[i].expiryDate) {
                expiringProductIds[nonExpiredProductCount] = i;
                nonExpiredProductCount++;
            }
        }

        uint256[] memory result = new uint256[](nonExpiredProductCount);
        for (uint256 i = 0; i < nonExpiredProductCount; i++) {
            result[i] = expiringProductIds[i];
        }
        return result;
    }


    /**
    * @dev Gets all products by a given manufacturer.
    * @param products The mapping of all products.
    * @param tokenCounter The total number of products.
    * @param productManufacturer The name of the manufacturer.
    * @return An array of IDs of the products by the given manufacturer.
    */
    function getProductsByManufacturer(mapping(uint256 => ProductLib.Product) storage products, uint256 tokenCounter, string memory productManufacturer) internal view returns (uint256[] memory) {
        require(bytes(productManufacturer).length > 0, "Manufacturer name cannot be empty");

        uint256[] memory productsByManufacturer = new uint256[](tokenCounter);
        uint256 productCount = 0;

        bytes32 manufacturerHash = keccak256(abi.encodePacked(productManufacturer));

        for (uint256 i = 0; i < tokenCounter; i++) {
            if (keccak256(abi.encodePacked(products[i].manufacturer)) == manufacturerHash) {
                productsByManufacturer[productCount] = i;
                productCount++;
            }
        }

        uint256[] memory result = new uint256[](productCount);
        for (uint256 i = 0; i < productCount; i++) {
            result[i] = productsByManufacturer[i];
        }
        return result;
    }   

}
