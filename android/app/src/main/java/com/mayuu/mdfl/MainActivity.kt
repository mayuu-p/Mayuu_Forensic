package com.mayuu.mdfl

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

private val Navy = Color(0xFF080D16)
private val Panel = Color(0xFF101A28)
private val Mint = Color(0xFF62DDBD)

class MainActivity : ComponentActivity() {
    private var selectedUri by mutableStateOf<Uri?>(null)
    private val picker = registerForActivityResult(ActivityResultContracts.OpenDocument()) { uri ->
        selectedUri = uri
        uri?.let { contentResolver.takePersistableUriPermission(it, Intent.FLAG_GRANT_READ_URI_PERMISSION) }
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme(colorScheme = darkColorScheme(primary = Mint, background = Navy, surface = Panel)) {
                Surface(Modifier.fillMaxSize(), color = Navy) {
                    Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(22.dp), verticalArrangement = Arrangement.spacedBy(18.dp)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text("◈", color = Mint, fontSize = 30.sp, fontWeight = FontWeight.Bold)
                            Spacer(Modifier.width(10.dp))
                            Column { Text("MDFL", color = Color.White, fontSize = 21.sp, fontWeight = FontWeight.Bold); Text("DIGITAL FORENSICS LAB", color = Color.LightGray, fontSize = 9.sp, letterSpacing = 2.sp) }
                        }
                        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                            Text("Evidence intelligence.", color = Color.White, fontSize = 27.sp, fontWeight = FontWeight.Bold)
                            Text("Select an image to begin a private metadata inspection.", color = Color(0xFF9BAABD), fontSize = 13.sp)
                        }
                        Card(colors = CardDefaults.cardColors(containerColor = Panel)) {
                            Column(Modifier.fillMaxWidth().padding(18.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                                Text("SOURCE EVIDENCE", color = Mint, fontSize = 10.sp, letterSpacing = 1.5.sp)
                                Text(if (selectedUri == null) "No image selected" else selectedUri.toString().substringAfterLast('/'), color = Color.White, fontSize = 13.sp)
                                Button(onClick = { picker.launch(arrayOf("image/jpeg", "image/png", "image/heic", "image/heif")) }, modifier = Modifier.fillMaxWidth()) { Text("Choose image") }
                                Text("Uses Android's system document picker. No background location permission is requested.", color = Color(0xFF9BAABD), fontSize = 11.sp)
                            }
                        }
                        Card(colors = CardDefaults.cardColors(containerColor = Panel)) {
                            Column(Modifier.fillMaxWidth().padding(18.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                Text("ANALYSIS STATUS", color = Mint, fontSize = 10.sp, letterSpacing = 1.5.sp)
                                Text("Client scaffold only", color = Color.White, fontWeight = FontWeight.SemiBold)
                                Text("Authenticated upload, SHA-256 report, EXIF extraction, secure token storage and evidence history are not connected yet. This app does not claim an image is authentic.", color = Color(0xFF9BAABD), fontSize = 12.sp, lineHeight = 18.sp)
                            }
                        }
                        Text("PRIVATE BY DESIGN  ·  MDFL DEVELOPMENT BUILD", color = Color(0xFF718197), fontSize = 9.sp, letterSpacing = 1.sp)
                    }
                }
            }
        }
    }
}