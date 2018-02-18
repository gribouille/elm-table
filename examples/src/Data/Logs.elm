module Data.Logs exposing (data)

import Data.Data exposing (Log, Level(..))

data : List Log
data = 
  [ Log 1  "2018-02-17 11:05:58" Info "Lorem ipsum dolor sit amet consectetur adipiscing elit."
  , Log 2  "2018-02-17 11:15:59" Error "Aenean eget magna ultrices ultricies nunc nec scelerisque enim."
  , Log 3  "2018-02-17 12:05:59" Warning "Proin vulputate urna nec enim aliquet non pharetra elit vehicula."
  , Log 4  "2018-02-17 13:06:02" Error "Aliquam venenatis turpis ac tellus suscipit varius."
  , Log 5  "2018-02-17 11:05:59" Info "Aliquam nec eros interdum hendrerit dui in tempor lectus."
  , Log 6  "2018-02-17 14:05:59" Warning "Suspendisse vel diam et ex viverra consectetur vitae sit amet orci."
  , Log 7  "2018-02-17 15:15:59" Warning "Nam aliquam arcu vel congue suscipit."
  , Log 8  "2018-02-17 11:05:59" Info "Morbi venenatis risus eget est scelerisque eu varius ex porta."
  , Log 9  "2018-02-17 11:05:02" Debug "Duis quis ipsum vulputate rhoncus sapien et ultrices turpis."
  , Log 10 "2018-02-17 11:17:59" Error "Aenean porta eros in mi pulvinar quis commodo erat facilisis."
  , Log 11 "2018-02-23 11:05:59" Error "Praesent volutpat metus vel dolor rhoncus cursus."
  , Log 12 "2018-02-17 12:05:59" Info "Duis sit amet eros ut ligula aliquet lobortis ac quis ligula."
  , Log 13 "2018-03-17 14:05:59" Info "Praesent ac odio vitae risus cursus iaculis ac a est."
  , Log 14 "2018-04-17 11:05:59" Warning "Nulla vestibulum leo vehicula laoreet ultricies."
  , Log 15 "2018-02-18 11:05:59" Warning "Maecenas euismod est condimentum euismod ipsum non vulputate massa."
  , Log 16 "2018-02-19 12:05:59" Info "Praesent maximus ex venenatis fermentum sem nec porta justo."
  , Log 17 "2018-02-20 18:05:59" Info "Donec tempus dui id felis malesuada at pulvinar diam congue."
  , Log 18 "2018-02-21 19:05:03" Error "Cras fermentum nibh vitae ligula scelerisque sed feugiat lorem porttitor."
  ]
  