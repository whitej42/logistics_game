class_name Driver
extends Resource

enum DriverStatus {WORKING, IDLE, AT_HOME, SICK}
enum DriverLicence {VAN, TRUCK}

@export var driver_id: String = "DRV_001"
@export var driver_name: String = "Jane Doe"
@export var status: DriverStatus = DriverStatus.IDLE
@export var licence: DriverLicence = DriverLicence.VAN
