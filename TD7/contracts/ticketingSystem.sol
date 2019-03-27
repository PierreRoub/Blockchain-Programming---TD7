pragma solidity ^0.5.0;


contract ticketingSystem {

    struct Artist
    {
        bytes32 name;
        address owner;
        int artistCategory;
        int ticketSold;
    }

    struct Venue
    {
        bytes32 name;
        int capacity;
        int standardComission;
        address owner;
    }

    struct Concert
    {
        uint concertDate;
        uint ticketPrice;
        uint totalSoldTicket;
        uint totalMoneyCollected;
        uint artistId;
        uint venueId;
        bool validatedByArtist;
        bool validatedByVenue;
    }

    struct Ticket
    {
    	uint concertId;
    	address payable owner;
        bool isAvailable;
        bool isAvailableForSale;
        uint amountPaid;
    }
    uint nextConcertId=1;
    uint artistId = 1;
    uint venueId =1;
    uint nextTicketId=1;
    uint oneDay = 60*60*24;
     
    mapping (uint => Artist) public artistsRegister;
    mapping (uint => Venue) public venuesRegister;
    mapping (uint => Concert) public concertsRegister;
    mapping (uint => Ticket) public ticketsRegister;

    function createArtist(bytes32 _name, int _artistCategory ) public {
        artistsRegister[artistId].name = _name;
        artistsRegister[artistId].artistCategory = _artistCategory;
        artistsRegister[artistId].owner = msg.sender;
        artistId += 1;
    }

    function modifyArtist(uint _artistId,bytes32 _newName, int _newArtistCategory, address _newOwner) public {
        require(msg.sender == artistsRegister[_artistId].owner);
        artistsRegister[_artistId].name = _newName;
        artistsRegister[_artistId].artistCategory = _newArtistCategory;
        artistsRegister[_artistId].owner = _newOwner;
    }
    
    function createVenue(bytes32 _name, int _capacity, int _comission) public {
        venuesRegister[venueId].name = _name;
        venuesRegister[venueId].capacity = _capacity;
        venuesRegister[venueId].standardComission = _comission;
        venuesRegister[venueId].owner = msg.sender;
        venueId += 1;
    }

    function modifyVenue(uint _venueId,bytes32 _newVenueName, int _newVenueCapacity,int _newVenueComission, address _newVenueAddress) public {
        require(msg.sender == venuesRegister[_venueId].owner);
        venuesRegister[_venueId].name = _newVenueName;
        venuesRegister[_venueId].capacity = _newVenueCapacity;
        venuesRegister[_venueId].standardComission = _newVenueComission;
        venuesRegister[_venueId].owner = _newVenueAddress;
    }

    function createConcert(uint _artistId, uint _venueId, uint _concertDate, uint _ticketPrice) public returns (uint concertId) {
        require(_concertDate >= now);
        require(artistsRegister[_artistId].owner != address(0));
        require(venuesRegister[_venueId].owner != address(0));
        concertsRegister[nextConcertId].concertDate = _concertDate;
        concertsRegister[nextConcertId].artistId = _artistId;
        concertsRegister[nextConcertId].venueId = _venueId;
        concertsRegister[nextConcertId].ticketPrice = _ticketPrice;
        concertsRegister[nextConcertId].totalSoldTicket=0;
        concertsRegister[nextConcertId].totalMoneyCollected=0;
        validateConcert(nextConcertId);
        concertId = nextConcertId;
        nextConcertId +=1;
  }
    function validateConcert(uint _concertId) public{
        require(concertsRegister[_concertId].concertDate >= now);
        if (venuesRegister[concertsRegister[_concertId].venueId].owner == msg.sender)
        {
            concertsRegister[_concertId].validatedByVenue = true;
        }
        if (artistsRegister[concertsRegister[_concertId].artistId].owner == msg.sender)
        {
            concertsRegister[_concertId].validatedByArtist = true;
        }
  }

     function emitTicket(uint _concertId, address payable _ticketOwner) public returns (uint ticketId) {
        require(artistsRegister[concertsRegister[_concertId].artistId].owner == msg.sender);
        ticketsRegister[_concertId].owner = _ticketOwner;
        ticketsRegister[_concertId].isAvailable = true;
        concertsRegister[_concertId].totalSoldTicket=concertsRegister[_concertId].totalSoldTicket+1;
        ticketId=nextTicketId;
        nextTicketId+=1;
     }

     function useTicket(uint _ticketId) public{
         require(msg.sender==ticketsRegister[_ticketId].owner);
         require(concertsRegister[ticketsRegister[_ticketId].concertId].concertDate +oneDay >= now);
         require(concertsRegister[ticketsRegister[_ticketId].concertId].validatedByVenue = true);
         ticketsRegister[_ticketId].owner= address(0);
         ticketsRegister[_ticketId].isAvailable=false;
     }

     function buyTicket(uint _concertId) public payable{
         concertsRegister[_concertId].totalSoldTicket += 1;
         concertsRegister[_concertId].totalMoneyCollected= concertsRegister[_concertId].totalSoldTicket * concertsRegister[_concertId].ticketPrice ;
         ticketsRegister[_concertId].concertId=_concertId;
         ticketsRegister[_concertId].amountPaid= concertsRegister[_concertId].ticketPrice;
         ticketsRegister[_concertId].isAvailable=true;
         ticketsRegister[_concertId].owner=msg.sender;
         ticketsRegister[_concertId].isAvailableForSale=false;
     }

     function transferTicket(uint _ticketId, address payable _newOwner) public {
         require(msg.sender==ticketsRegister[_ticketId].owner);
         ticketsRegister[_ticketId].owner= _newOwner;
     }
}