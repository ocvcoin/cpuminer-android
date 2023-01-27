package com.ocvcoin.ocvminer;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class BatteryReceiver extends BroadcastReceiver {

	@Override
	public void onReceive(Context arg0, Intent arg1) {
		((OCVMinerApplication) arg0).handleBatteryEvent(arg1);
	}
}
