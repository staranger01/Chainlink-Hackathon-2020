// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/Math.sol";

contract InsurancePool is AccessControl, Ownable {
    using SafeMath for uint256;
    
    struct Disbursement {
        address hospitalAddress;
        address patientAddress;
        bytes32 ailment;
        uint256 cost;
        uint256 timestamp;
        bool isPaid;
    }

    uint256 public memberCount = 0;
    uint256 public memberMaxCount = 1000;
    uint256 public coverageMultiple = 10;
    uint256 public price = 3 ether;
    uint256 public totalValue = 0;
    uint256 public flatLimit = price.mult(coverageMultiple);
    uint256 public poolTotal = 0;
    
    mapping(address => bool) memberAutoRenew;
    mapping(address => uint256) memberDisbursements;
    mapping(uint => Disbursement) disbursementLog;

    bytes32 public constant CONTRACT_OWNER_ROLE = keccack256("CONTRACT_OWNER");
    bytes32 public constant HOSPITAL_ROLE = keccak256("HOSPITAL");
    bytes32 public constant APPROVED_MEMBER_ROLE = keccak256("APPROVED_MEMBER");
    bytes32 public constant INSURED_MEMBER_ROLE = keccak256("INSURED_MEMBER");

    mapping(address => bool) memberAutoRenew;
    uint public duration = 365 days;
    uint public disbursementCount = 0;

    constructor() public {
        owner = msg.sender;
        _setupRole(CONTRACT_OWNER_ROLE, msg.sender);
        _setRoleAdmin(HOSPITAL_ROLE, CONTRACT_OWNER_ROLE);
        _setRoleAdmin(APPROVED_MEMBER_ROLE, CONTRACT_OWNER_ROLE);
        _setRoleAdmin(INSURED_MEMBER_ROLE, APPROVED_MEMBER_ROLE);
    }

    /**
     * Contract owner grants APPROVED_MEMBER_ROLE so member can purchase insurance
     */
    function ApproveMember(address memberAddress) public onlyOwner {
        
        grantRole(APPROVED_MEMBER_ROLE, memberAddress);
    }

    /**
     * Contract owner grants HOSPITAL_ROLE so hospital can request disbursements
     */
    function ApproveHospital(address hospitalAddress) public onlyOwner {
        grantRole(HOSPITAL_ROLE, providerAddress);
    }

    /**
     * View member payment history since purchase
     */
    function ViewMemberDisbursements(address memberAddress) public view returns (uint)
    {
        return memberDisbursements[memberAddress];
    }

    /**
     * Hospital calls this to request payment from the pool
     */
    function RequestDisbursement(address memberAddress, bytes32 procedure, uint256 amount)
    {
        // Step 1: Check member balance
        require(memberDisbursements.add(amount) < flatLimit);
        // Step 2: Increase member disbursements
        memberDisbursements[memberAddress] = memberDisbursements[memberAddress].add(amount);
        // Step 3: Store the disbursement request
        // !!! TODO !!!
        disbursementCount += 1;
        uint disbursementID = disbursementCount;
        disbursementLog[disbursementID] = Disbursement({
            addrHospital: msg.sender, 
            patientAddress: memberAddress,
            ailment: procedure, 
            cost: amount,
            date: block.timestamp,
            isPaid: false
            });
    }    

    /**  
     * Contract owner OR patient can release payment to the hospital
    */
    function ApproveDisbursement(uint disbursementID)
    {

    }


    /**
     * Member purchases the insurance
     */
    function PurchaseInsurance(bool setAutoRenew) payable public
    {
        // 1: Check for member approved and they are the active member
        require(hasRole(APPROVED_MEMBER_ROLE, msg.sender) && !hasRole(ACTIVE_MEMBER_ROLE, msg.sender));
        // 2: Check payment amount and deduct amount in ETH
        require(msg.value = price);
        // !!! TODO !!!

        // 3: Grant approved role
        grantRole(ACTIVE_MEMBER_ROLE, msg.sender);

        // 4: Update member count and validate not above max
        memberCount = getRoleMemberCount();
        require(memberCount < memberMaxCount)

        // 5: Update coverage limits (no more than the pool balance)
        flatLimit = min(price.mult(coverageMultiple), poolTotal);

        // 6: Queue expiration job using ChainLink alarm clock
        // !!! TODO !!!
    }

    function getBalance () view public returns(uint256){
        return (memPool[msg.sender]);
    }
    function GetAutoRenew () view public returns (bool){
        return memberAutoRenew[msg.sender];
    }
} 