pragma solidity ^0.8.20;

contract HotelBooking {
    
    struct Booking {
        uint256 roomId;
        uint256 checkInDate;
        uint256 checkOutDate;
        address guest;
        bool isActive;
    }
    
    uint256 public nextBookingId;
    mapping(uint256 => Booking) public bookings;
    
    event BookingCreated(uint256 bookingId, uint256 roomId, uint256 checkInDate, uint256 checkOutDate, address guest);
    event BookingCanceled(uint256 bookingId);
    
    constructor() {
        nextBookingId = 1;
    }
    
    function bookHotel(uint256 _roomId, uint256 _checkInDate, uint256 _checkOutDate) external {
        require(_checkInDate < _checkOutDate, "Invalid date range");
        require(_roomId > 0, "Invalid room ID");
        require(!isRoomBooked(_roomId, _checkInDate, _checkOutDate), "Room is already booked");
        
        Booking memory newBooking = Booking({
            roomId: _roomId,
            checkInDate: _checkInDate,
            checkOutDate: _checkOutDate,
            guest: msg.sender,
            isActive: true
        });
        
        bookings[nextBookingId] = newBooking;
        emit BookingCreated(nextBookingId, _roomId, _checkInDate, _checkOutDate, msg.sender);
        
        nextBookingId++;
    }
    
    function cancelBooking(uint256 _bookingId) external {
        Booking storage booking = bookings[_bookingId];
        
        require(booking.guest == msg.sender, "Only the guest can cancel the booking");
        require(booking.isActive, "Booking is already canceled");
        
        booking.isActive = false;
        emit BookingCanceled(_bookingId);
    }
    
    function isRoomBooked(uint256 _roomId, uint256 _checkInDate, uint256 _checkOutDate) internal view returns (bool) {
        for (uint256 i = 1; i < nextBookingId; i++) {
            Booking storage booking = bookings[i];
            if (booking.isActive &&
                booking.roomId == _roomId &&
                (_checkInDate >= booking.checkInDate && _checkInDate < booking.checkOutDate ||
                _checkOutDate > booking.checkInDate && _checkOutDate <= booking.checkOutDate)) {
                return true;
            }
        }
        return false;
    }
}
