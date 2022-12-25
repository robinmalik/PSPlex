Function ConvertFrom-UnixTime($UnixDate)
{
	[timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($UnixDate))
}