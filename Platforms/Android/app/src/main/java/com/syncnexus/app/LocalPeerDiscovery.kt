package com.syncnexus.app

import android.content.Context
import android.net.nsd.NsdManager
import android.net.nsd.NsdServiceInfo
import android.os.Build
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

data class DiscoveredDevice(
    val name: String,
    val host: String,
    val port: Int
)

/**
 * Android 局域網點對點零設定發現服務 (mDNS / Network Service Discovery)
 * 借鏡 LocalSend 與 Syncthing：在同 Wi-Fi 內自動尋找 Mac 與其他 Android 設備
 */
class LocalPeerDiscovery(private val context: Context) {

    private val serviceType = "_syncnexus._tcp."
    // Peer discovery is a convenience: if the system refuses (permission, no Wi-Fi stack), the app must still open.
    private val nsdManager: NsdManager? = try {
        context.getSystemService(Context.NSD_SERVICE) as? NsdManager
    } catch (_: Exception) { null }

    private val _nearbyDevices = MutableStateFlow<List<DiscoveredDevice>>(emptyList())
    val nearbyDevices: StateFlow<List<DiscoveredDevice>> = _nearbyDevices.asStateFlow()

    private var registrationListener: NsdManager.RegistrationListener? = null
    private var discoveryListener: NsdManager.DiscoveryListener? = null

    fun start() {
        if (nsdManager == null) return
        registerService()
        discoverServices()
    }

    fun stop() {
        registrationListener?.let {
            try { nsdManager?.unregisterService(it) } catch (_: Exception) {}
        }
        discoveryListener?.let {
            try { nsdManager?.stopServiceDiscovery(it) } catch (_: Exception) {}
        }
    }

    private fun registerService() {
        val serviceInfo = NsdServiceInfo().apply {
            serviceName = "Android-${Build.MODEL}"
            serviceType = this@LocalPeerDiscovery.serviceType
            port = 53530
        }

        registrationListener = object : NsdManager.RegistrationListener {
            override fun onServiceRegistered(NsdServiceInfo: NsdServiceInfo) {}
            override fun onRegistrationFailed(serviceInfo: NsdServiceInfo, errorCode: Int) {}
            override fun onServiceUnregistered(arg0: NsdServiceInfo) {}
            override fun onUnregistrationFailed(serviceInfo: NsdServiceInfo, errorCode: Int) {}
        }

        try {
            nsdManager?.registerService(serviceInfo, NsdManager.PROTOCOL_DNS_SD, registrationListener)
        } catch (_: Exception) {}
    }

    private fun discoverServices() {
        discoveryListener = object : NsdManager.DiscoveryListener {
            override fun onDiscoveryStarted(regType: String) {}

            override fun onServiceFound(service: NsdServiceInfo) {
                if (service.serviceType.contains("syncnexus")) {
                    resolveService(service)
                }
            }

            override fun onServiceLost(service: NsdServiceInfo) {
                val current = _nearbyDevices.value.toMutableList()
                current.removeAll { it.name == service.serviceName }
                _nearbyDevices.value = current
            }

            override fun onDiscoveryStopped(serviceType: String) {}
            override fun onStartDiscoveryFailed(serviceType: String, errorCode: Int) {}
            override fun onStopDiscoveryFailed(serviceType: String, errorCode: Int) {}
        }

        try {
            nsdManager?.discoverServices(serviceType, NsdManager.PROTOCOL_DNS_SD, discoveryListener)
        } catch (_: Exception) {}
    }

    private fun resolveService(serviceInfo: NsdServiceInfo) {
        try { nsdManager?.resolveService(serviceInfo, object : NsdManager.ResolveListener {
            override fun onResolveFailed(serviceInfo: NsdServiceInfo, errorCode: Int) {}

            override fun onServiceResolved(resolved: NsdServiceInfo) {
                val device = DiscoveredDevice(
                    name = resolved.serviceName,
                    host = resolved.host?.hostAddress ?: "local",
                    port = resolved.port
                )
                val current = _nearbyDevices.value.toMutableList()
                if (current.none { it.name == device.name }) {
                    current.add(device)
                    _nearbyDevices.value = current
                }
            }
        }) } catch (_: Exception) {}
    }
}
