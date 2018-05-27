pragma solidity ^0.4.4;

import "@aragon/os/contracts/apps/AragonApp.sol";
import "@aragon/os/contracts/lib/zeppelin/math/SafeMath.sol";
import "@aragon/os/contracts/apps/TokenManager.sol";


contract Slicer is AragonApp {
    using SafeMath for uint256;

    /// Events
    event NewContribution(
        address indexed receiver, 
        uint256 contribution, 
        uint256 state
    );
    event NewExpend(
        uint256 expense
    );
    event NewMember(
        address member, 
        uint256 fairSalary
    );
    //event MemberRemoved();
    
    /// State
    address[] public members;
    uint256 public wellValue;

    // Multiplier to adjust weight of ETH contributions.
    uint ethMultiplier;
    // Multiplier to adjust weight of Non ETH contributions.
    uint nonEthMultiplier;

    mapping (address => uint256) fairSalaries;
    mapping (address => uint256) ethContributions;

    /// ACL
    bytes32 constant public MEMBER_ROLE = keccak256("MEMBER_ROLE");
    bytes32 constant public ADMIN_ROLE = keccak256("ADMIN_ROLE");

    /**
    * @notice Initi
    * @param _ethMultiplier Default multiplier for ETH contributions
    * @param _nonEthMultiplier Defalut multiplier for Non ETH contributions
    */
    function initialize(
        TokenManager _sliceManager, 
        uint256 _ethMultiplier, 
        uint256 _nonEthMultiplier) 
        onlyInit external 
    {
        ethMultiplier = _ethMultiplier;
        nonEthMultiplier = _nonEthMultiplier;
    }

    /**
     * @notice Assign slices to address
     * @param _receiver Address of deposited slices
     * @param _contribution Amount of the contribution 
     * @param _state Type of the contribution (Time, ETH, Supplies, Equipment, Sales, Royalty, Facilities, Other)
     */
    function slice(address _receiver, uint256 _contribution, uint _state) auth(MEMBER_ROLE) external {
        uint256 amount;

        // Contribution with Time
        if ( _state = 0) {
            amount = fairSalaries[_reciver] * _contribution * nonEthMultiplier;
            _sliceManager.mint(_receiver, _amount);
        // Contribution with ETH
        } else if ( _sate = 1) {
            ethContributions[_receiver] = _contribution;
            wellValue += _contribution;
        // Other contributions
        } else {
            amount = _contribution * nonEthMultiplier;
            _sliceManager.mint(_receiver, _amount);
        }

        emit NewContribution(_receiver, _contribution, _state);

        /**
        *   In the model there are many more possilbe contributions:
        *       - Equipments
        *       - Sales 
        *       - Royalty 
        *       - Facilities
        *   
        *   We decide not include these logic for the MVP on the event.
        */
    }

    /**
     * @notice The DAO expend ETH => slices are mint for each member proportionally to the ETH held on the Well
     * @param _expense  ETH the DAO spent of the Well
     */
    function expend(uint256 _expense) auth(MEMBER_ROLE) external {
        require (wellValue >= _amount);
        require (members.length() > 0);
        uint256 amount;

        for (uint256 i = 0; i < members.length(); i = i.add(1)){
            if (ethContributions[member[i]] > 0) {
                // amount of ETH to substract from the member contribution
                amount = (ethContributions[member[i]] / wellValue) * _expense;
                ethContributions[member[i]] -= amount;
                // amount of slices to be minted
                amount *= ethMultiplier;
                _sliceManager.mint(member[i], amount);
            }
        }

        wellValue -= _expense;

        emit NewExpend(_expense);
    }

    /**
     * @notice Assign slices to address
     * @param _member Member added to the members of the DAO
     * @param _fairSalary Default Fair Market Salary on ETH per hour
     */
    function addMember(address _member, uint256 _fairSalary) auth(ADMIN_ROLE) external {
        members.push(_member);
        fairSalaries[_member] = _fairSalary;

        emit NewMember(_member, _fairSalary);
        /**
        *  For these accion ideally the DAO take a vote on the members to approve new member.
        *  
        */ 
    }

    /**
     * @notice Assign slices to address
     * @param _remove Address of the member removed
     * @param _cause Cause the member was remove/terminated
     */
    function removeMember(address _remove, uint _cause) auth(ADMIN_ROLE) external {
        /**
        *   In the model there are 4 reasons for a member to be remove/terminated:
        *       - Terminate for Good Reason
        *       - Terminate for No Good Reason 
        *       - Resign for Good Reason 
        *       - Resign for No Good Reason
        *   
        *   Each one can result in two scenarios:
        *       1. Burn of the slices of that member
        *       2. The DAO purchase the slices of that memberm, if possible
        *
        *   We decide not include these logic for the MVP on the event.
        */ 
    }


    /**
     * @notice Assign a Fair Market Salary to the address 
     * @param _receiver Address assigned the Fair Market Salary
     * @param _value Value of the Fair Market Salary on ETH per hour
     */
    function assignFairMarketSalary(address _assigned, uint256 _value) auth(ADMIN_ROLE) external {
        fairSalaries[_assinged] = _value;
        /**
        *  For these accion ideally the DAO take a vote on the members to approve the assignment.
        *  
        */ 
    }

    /**
     * @notice Assign value to the ETH multiplier
     * @param _ethMultiplier Value assigned to ETH multiplier
     */
    function assignEthMultiplier(uint64 _ethMultiplier) auth(ADMIN_ROLE) external {
        ethMultiplier = _ethMultiplier;
    }

    /**
     * @notice Assign value to the Non ETH multiplier
     * @param _nonEthMultiplier Value assigned to Non ETH multiplier
     */
    function assignNonEthMultiplier(uint64 _nonEthMultiplier) auth(ADMIN_ROLE) external {
        nonEthMultiplier = _nonEthMultiplier;
    }

}