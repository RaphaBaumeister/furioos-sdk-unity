namespace Mindstorm.WM
{
	public enum TouchEvent : int
	{
	    TOUCHEVENTF_MOVE = 0x0001,
	    TOUCHEVENTF_DOWN = 0x0002,
	    TOUCHEVENTF_UP = 0x0004,
	    TOUCHEVENTF_INRANGE = 0x0008,
	    TOUCHEVENTF_PRIMARY = 0x0010,
	    TOUCHEVENTF_NOCOALESCE = 0x0020,
	    TOUCHEVENTF_PEN = 0x0040
	}
}