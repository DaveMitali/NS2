#creates a simulator object
set ns [new Simulator]    

#set color to cbr flow
#written after creation of simulator object
$ns color 1 Blue
$ns color 2 Red

#opens file out.nam for writing and gives it to file handle 'nf'
#tells the simulation object that we created the above file to write all simulation data
set nf [open out.nam w] 
$ns namtrace-all $nf

#finish procedure that closes the trace file and starts nam    
proc finish {} {    
        global ns nf
        $ns flush-trace
        close $nf
        exec nam out.nam &
        exit 0
}

#$ns node creates a new node object
#4 nodes are created and assigned to handles n0, n1, n2 and n3
set n0 [$ns node]    
set n1 [$ns node]    
set n2 [$ns node]
set n3 [$ns node]

#for star topology of 4 nodes we need 3 duplex links
#creates a duplex-link between n0-n2,n1-n2,n3-n2 with bandwidth 1Mb, delay of 10ms and DropTail queue
$ns duplex-link $n0 $n2 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n3 $n2 1Mb 10ms DropTail

#since topology is of awkward orientation till here we re-orient it
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n3 $n2 orient left

#create 2 UDP cbr agents at n0 and n1 (sources) 
#create a null agent at n3 (sink)
set udp0 [new Agent/UDP]
set udp1 [new Agent/UDP]

#assign color to UDP agents
$udp0 set class_ 1
$udp1 set class_ 2
$ns attach-agent $n0 $udp0
$ns attach-agent $n1 $udp1
set null3 [new Agent/Null]
$ns attach-agent $n3 $null3

#create cbr source at n0 and n1 and attach to agents
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 500
$cbr1 set interval_ 0.005
$cbr1 attach-agent $udp1

#connect 2 cbr agents to null agent
$ns connect $udp0 $null3
$ns connect $udp1 $null3

#first cbr agent starts sending at 0.5 seconds and stops sending at 4.5 seconds
#second cbr agent starts sending at 1 seconds and stops sending at 4 seconds
$ns at 0.5 "$cbr0 start"
$ns at 4.5 "$cbr0 stop"
$ns at 1 "$cbr1 start"
$ns at 4 "$cbr1 stop"

#tells the simulator object to execute the finish procedure after 5.0 seconds of simulation time
$ns at 5.0 "finish"    

#starts simulation
$ns run   