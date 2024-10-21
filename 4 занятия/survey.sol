// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

contract Survey {
    string public proposal;
    uint public maxCount;
    uint public surveyYes;
    uint public surveyNo;
    uint public surveyNS;
    bool public surveyEnded;

    mapping(address => bool) public hasSurvey;

    event SurveyEnded(uint surveyYes, uint surveyNo, uint surveyNS);

    constructor(string memory _proposal, uint _maxCount) {
        proposal = _proposal;
        maxCount = _maxCount;
        surveyYes = 0;
        surveyNo = 0;
        surveyNS = 0;
        surveyEnded = false;
    }

    modifier onlyActiveSurvey() {
        require(!surveyEnded, "Survey has already ended");
        _;
    }

    modifier onlyOncePerAddress() {
        require(!hasSurvey[msg.sender], "You have already taken part in the survey");
        _;
    }

    function SurveyYes() public onlyActiveSurvey onlyOncePerAddress {
        surveyYes++;
        hasSurvey[msg.sender] = true;
        checkSurveyEnd();
    }

    function SurveyNo() public onlyActiveSurvey onlyOncePerAddress {
        surveyNo++;
        hasSurvey[msg.sender] = true;
        checkSurveyEnd();
    }

    function SurveyNS() public onlyActiveSurvey onlyOncePerAddress {
        surveyNS++;
        hasSurvey[msg.sender] = true;
        checkSurveyEnd();
    }

    function checkSurveyEnd() private {
        if (surveyYes + surveyNo + surveyNS >= maxCount) {
            surveyEnded = true;
            emit SurveyEnded(surveyYes, surveyNo, surveyNS);
        }
    }

    // function getSurveyResults() public view returns (uint, uint, uint) {
    //     require(surveyEnded, "Survey is still ongoing");
    //     return (surveyYes, surveyNo, surveyNS);
    // }

    function getSurveyResultsString() public view returns (string memory) {
        require(surveyEnded, "Survey is still ongoing");
        return string(abi.encodePacked(
            "Proposal: ", proposal, "; ",
            "Survey YES: ", Strings.toString(surveyYes), "; ",
            "Survey NO: ", Strings.toString(surveyNo), "; ",
            "Survey NOT STATED: ", Strings.toString(surveyNS)
        ));
    }

    function getRemainingSurvey() public view returns (uint) {
        return maxCount - (surveyYes + surveyNo + surveyNS);
    }
}