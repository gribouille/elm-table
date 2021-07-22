module Movies exposing (..)


type alias Movie =
    { id : String
    , title : String
    , original_title : String
    , original_title_romanised : String
    , description : String
    , director : String
    , producer : String
    , release_date : Int
    , running_time : Int
    , rt_score : Int
    , people : List Person
    }


type alias Person =
    { id : String
    , name : String
    , gender : String
    , age : Maybe Int
    , eye_color : String
    , hair_color : String
    }


movies =
    [ { id = "2baf70d1-42bb-4437-b551-e5fed5a87abe"
      , title = "Castle in the Sky"
      , original_title = "天空の城ラピュタ"
      , original_title_romanised = "Tenkū no shiro Rapyuta"
      , description = "The orphan Sheeta inherited a mysterious crystal that links her to the mythical sky-kingdom of Laputa. With the help of resourceful Pazu and a rollicking band of sky pirates, she makes her way to the ruins of the once-great civilization. Sheeta and Pazu must outwit the evil Muska, who plans to use Laputa's science to make himself ruler of the world."
      , director = "Hayao Miyazaki"
      , producer = "Isao Takahata"
      , release_date = 1986
      , running_time = 124
      , rt_score = 95
      , people =
            [ { id = "fe93adf2-2f3a-4ec4-9f68-5422f1b87c011"
              , name = "Pazu"
              , gender = "Male"
              , age = Just 13
              , eye_color = "Black"
              , hair_color = "Brown"
              }
            , { id = "598f7048-74ff-41e0-92ef-87dc1ad980a92"
              , name = "Lusheeta Toel Ul Laputa"
              , gender = "Female"
              , age = Just 13
              , eye_color = "Black"
              , hair_color = "Black"
              }
            , { id = "3bc0b41e-3569-4d20-ae73-2da329bf07863"
              , name = "Dola"
              , gender = "Female"
              , age = Just 60
              , eye_color = "Black"
              , hair_color = "Peach"
              }
            , { id = "abe886e7-30c8-4c19-aaa5-d666e60d14de4"
              , name = "Romska Palo Ul Laputa"
              , gender = "Male"
              , age = Just 33
              , eye_color = "Black"
              , hair_color = "Brown"
              }
            , { id = "e08880d0-6938-44f3-b179-81947e7873fc5"
              , name = "Uncle Pom"
              , gender = "Male"
              , age = Nothing
              , eye_color = "Black"
              , hair_color = "White"
              }
            ]
      }
    , { id = "12cfb892-aac0-4c5b-94af-521852e46d6a"
      , title = "Grave of the Fireflies"
      , original_title = "火垂るの墓"
      , original_title_romanised = "Hotaru no haka"
      , description = ""
      , director = "Isao Takahata"
      , producer = "Toru Hara"
      , release_date = 1988
      , running_time = 89
      , rt_score = 97
      , people =
            [ { id = "abe886e7-30c8-4c19-aaa5-d666e60d14de6"
              , name = "Romska Palo Ul Laputa"
              , gender = "Male"
              , age = Just 33
              , eye_color = "Black"
              , hair_color = "Brown"
              }
            , { id = "e08880d0-6938-44f3-b179-81947e7873fc7"
              , name = "Uncle Pom"
              , gender = "Male"
              , age = Nothing
              , eye_color = "Black"
              , hair_color = "White"
              }
            ]
      }
    , { id = "58611129-2dbc-4a81-a72f-77ddfc1b1b49"
      , title = "My Neighbor Totoro"
      , original_title = "となりのトトロ"
      , original_title_romanised = "Tonari no Totoro"
      , description = "Two sisters move to the country with their father in order to be closer to their hospitalized mother, and discover the surrounding trees are inhabited by Totoros, magical spirits of the forest. When the youngest runs away from home, the older sister seeks help from the spirits to find her."
      , director = "Hayao Miyazaki"
      , producer = "Hayao Miyazaki"
      , release_date = 1988
      , running_time = 86
      , rt_score = 93
      , people =
            [ { id = "5c83c12a-62d5-4e92-8672-33ac76ae1fa08"
              , name = "General Muoro"
              , gender = "Male"
              , age = Nothing
              , eye_color = "Black"
              , hair_color = "None"
              }
            , { id = "3f4c408b-0bcc-45a0-bc8b-20ffc67a2ede9"
              , name = "Duffi"
              , gender = "Male"
              , age = Nothing
              , eye_color = "Dark brown"
              , hair_color = "Dark brown"
              }
            , { id = "fcb4a2ac-5e41-4d54-9bba-33068db083c10"
              , name = "Louis"
              , gender = "Male"
              , age = Just 30
              , eye_color = "Dark brown"
              , hair_color = "Dark brown"
              }
            ]
      }
    , { id = "ea660b10-85c4-4ae3-8a5f-41cea3648e3e"
      , title = "Kiki's Delivery Service"
      , original_title = "魔女の宅急便"
      , original_title_romanised = "Majo no takkyūbin"
      , description = "A young witch, on her mandatory year of independent life, finds fitting into a new community difficult while she supports herself by running an air courier service."
      , director = "Hayao Miyazaki"
      , producer = "Hayao Miyazaki"
      , release_date = 1989
      , running_time = 102
      , rt_score = 96
      , people =
            [ { id = "e08880d0-6938-44f3-b179-81947e7873f11"
              , name = "Uncle Pom"
              , gender = "Male"
              , age = Nothing
              , eye_color = "Black"
              , hair_color = "White"
              }
            , { id = "5c83c12a-62d5-4e92-8672-33ac76ae1fa12"
              , name = "General Muoro"
              , gender = "Male"
              , age = Nothing
              , eye_color = "Black"
              , hair_color = "None"
              }
            ]
      }
    , { id = "4e236f34-b981-41c3-8c65-f8c9000b94e7"
      , title = "Only Yesterday"
      , original_title = "おもひでぽろぽろ"
      , original_title_romanised = "Omoide poro poro"
      , description = "It’s 1982, and Taeko is 27 years old, unmarried, and has lived her whole life in Tokyo. She decides to visit her family in the countryside, and as the train travels through the night, memories flood back of her younger years: the first immature stirrings of romance, the onset of puberty, and the frustrations of math and boys. At the station she is met by young farmer Toshio, and the encounters with him begin to reconnect her to forgotten longings. In lyrical switches between the present and the past, Taeko contemplates the arc of her life, and wonders if she has been true to the dreams of her childhood self."
      , director = "Isao Takahata"
      , producer = "Toshio Suzuki"
      , release_date = 1991
      , running_time = 118
      , rt_score = 100
      , people =
            [ { id = "f6f2c477-98aa-4796-b9aa-8209fdeed6b13"
              , name = "Henri"
              , gender = "Male"
              , age = Nothing
              , eye_color = "Dark brown"
              , hair_color = "Reddish brown"
              }
            , { id = "05d8d01b-0c2f-450e-9c55-aa0daa3483814"
              , name = "Motro"
              , gender = "Male"
              , age = Nothing
              , eye_color = "Dark brown"
              , hair_color = "None"
              }
            ]
      }
    , { id = "ebbb6b7c-945c-41ee-a792-de0e43191bd8"
      , title = "Porco Rosso"
      , original_title = "紅の豚"
      , original_title_romanised = "Kurenai no buta"
      , description = "Porco Rosso, known in Japan as Crimson Pig (Kurenai no Buta) is the sixth animated film by Hayao Miyazaki and released in 1992. You're introduced to an Italian World War I fighter ace, now living as a freelance bounty hunter chasing 'air pirates' in the Adriatic Sea. He has been given a curse that changed his head to that of a pig. Once called Marco Pagot, he is now known to the world as 'Porco Rosso', Italian for 'Red Pig.'"
      , director = "Hayao Miyazaki"
      , producer = "Toshio Suzuki"
      , release_date = 1992
      , running_time = 93
      , rt_score = 94
      , people =
            [ { id = "fcb4a2ac-5e41-4d54-9bba-33068db083c15"
              , name = "Louis"
              , gender = "Male"
              , age = Just 30
              , eye_color = "Dark brown"
              , hair_color = "Dark brown"
              }
            , { id = "2cb76c15-772a-4cb3-9919-3652f56611d16"
              , name = "Charles"
              , gender = "Male"
              , age = Nothing
              , eye_color = "Dark brown"
              , hair_color = "Light brown"
              }
            , { id = "f6f2c477-98aa-4796-b9aa-8209fdeed6b17"
              , name = "Henri"
              , gender = "Male"
              , age = Nothing
              , eye_color = "Dark brown"
              , hair_color = "Reddish brown"
              }
            ]
      }
    , { id = "1b67aa9a-2e4a-45af-ac98-64d6ad15b16c"
      , title = "Pom Poko"
      , original_title = "平成狸合戦ぽんぽこ"
      , original_title_romanised = "Heisei tanuki gassen Ponpoko"
      , description = "As the human city development encroaches on the raccoon population's forest and meadow habitat, the raccoons find themselves faced with the very real possibility of extinction. In response, the raccoons engage in a desperate struggle to stop the construction and preserve their home."
      , director = "Isao Takahata"
      , producer = "Toshio Suzuki"
      , release_date = 1994
      , running_time = 119
      , rt_score = 78
      , people =
            []
      }
    , { id = "ff24da26-a969-4f0e-ba1e-a122ead6c6e3"
      , title = "Whisper of the Heart"
      , original_title = "耳をすませば"
      , original_title_romanised = "Mimi wo sumaseba"
      , description = "Shizuku lives a simple life, dominated by her love for stories and writing. One day she notices that all the library books she has have been previously checked out by the same person: 'Seiji Amasawa'. Curious as to who he is, Shizuku meets a boy her age whom she finds infuriating, but discovers to her shock that he is her 'Prince of Books'. As she grows closer to him, she realises that he merely read all those books to bring himself closer to her. The boy Seiji aspires to be a violin maker in Italy, and it is his dreams that make Shizuku realise that she has no clear path for her life. Knowing that her strength lies in writing, she tests her talents by writing a story about Baron, a cat statuette belonging to Seiji's grandfather."
      , director = "Yoshifumi Kondō"
      , producer = "Toshio Suzuki"
      , release_date = 1995
      , running_time = 111
      , rt_score = 91
      , people =
            [ { id = "598f7048-74ff-41e0-92ef-87dc1ad980a19"
              , name = "Lusheeta Toel Ul Laputa"
              , gender = "Female"
              , age = Just 13
              , eye_color = "Black"
              , hair_color = "Black"
              }
            , { id = "3bc0b41e-3569-4d20-ae73-2da329bf07820"
              , name = "Dola"
              , gender = "Female"
              , age = Just 60
              , eye_color = "Black"
              , hair_color = "Peach"
              }
            ]
      }
    , { id = "0440483e-ca0e-4120-8c50-4c8cd9b965d6"
      , title = "Princess Mononoke"
      , original_title = "もののけ姫"
      , original_title_romanised = "Mononoke hime"
      , description = "Ashitaka, a prince of the disappearing Ainu tribe, is cursed by a demonized boar god and must journey to the west to find a cure. Along the way, he encounters San, a young human woman fighting to protect the forest, and Lady Eboshi, who is trying to destroy it. Ashitaka must find a way to bring balance to this conflict."
      , director = "Hayao Miyazaki"
      , producer = "Toshio Suzuki"
      , release_date = 1997
      , running_time = 134
      , rt_score = 92
      , people =
            [ { id = "3bc0b41e-3569-4d20-ae73-2da329bf07821"
              , name = "Dola"
              , gender = "Female"
              , age = Just 60
              , eye_color = "Black"
              , hair_color = "Peach"
              }
            , { id = "abe886e7-30c8-4c19-aaa5-d666e60d14d22"
              , name = "Romska Palo Ul Laputa"
              , gender = "Male"
              , age = Just 33
              , eye_color = "Black"
              , hair_color = "Brown"
              }
            ]
      }
    , { id = "45204234-adfd-45cb-a505-a8e7a676b114"
      , title = "My Neighbors the Yamadas"
      , original_title = "ホーホケキョ となりの山田くん"
      , original_title_romanised = "Hōhokekyo tonari no Yamada-kun"
      , description = "The Yamadas are a typical middle class Japanese family in urban Tokyo and this film shows us a variety of episodes of their lives. With tales that range from the humourous to the heartbreaking, we see this family cope with life's little conflicts, problems and joys in their own way."
      , director = "Isao Takahata"
      , producer = "Toshio Suzuki"
      , release_date = 1999
      , running_time = 104
      , rt_score = 75
      , people =
            [ { id = "e08880d0-6938-44f3-b179-81947e7873f23"
              , name = "Uncle Pom"
              , gender = "Male"
              , age = Nothing
              , eye_color = "Black"
              , hair_color = "White"
              }
            ]
      }
    , { id = "dc2e6bd1-8156-4886-adff-b39e6043af0c"
      , title = "Spirited Away"
      , original_title = "千と千尋の神隠し"
      , original_title_romanised = "Sen to Chihiro no kamikakushi"
      , description = "Spirited Away is an Oscar winning Japanese animated film about a ten year old girl who wanders away from her parents along a path that leads to a world ruled by strange and unusual monster-like animals. Her parents have been changed into pigs along with others inside a bathhouse full of these creatures. Will she ever see the world how it once was?"
      , director = "Hayao Miyazaki"
      , producer = "Toshio Suzuki"
      , release_date = 2001
      , running_time = 124
      , rt_score = 97
      , people =
            [ { id = "5c83c12a-62d5-4e92-8672-33ac76ae1fa24"
              , name = "General Muoro"
              , gender = "Male"
              , age = Nothing
              , eye_color = "Black"
              , hair_color = "None"
              }
            , { id = "3f4c408b-0bcc-45a0-bc8b-20ffc67a2ed25"
              , name = "Duffi"
              , gender = "Male"
              , age = Nothing
              , eye_color = "Dark brown"
              , hair_color = "Dark brown"
              }
            ]
      }
    , { id = "90b72513-afd4-4570-84de-a56c312fdf81"
      , title = "The Cat Returns"
      , original_title = "猫の恩返し"
      , original_title_romanised = "Neko no ongaeshi"
      , description = "Haru, a schoolgirl bored by her ordinary routine, saves the life of an unusual cat and suddenly her world is transformed beyond anything she ever imagined. The Cat King rewards her good deed with a flurry of presents, including a very shocking proposal of marriage to his son! Haru embarks on an unexpected journey to the Kingdom of Cats where her eyes are opened to a whole other world."
      , director = "Hiroyuki Morita"
      , producer = "Toshio Suzuki"
      , release_date = 2002
      , running_time = 75
      , rt_score = 89
      , people =
            [ { id = "3f4c408b-0bcc-45a0-bc8b-20ffc67a2ed26"
              , name = "Duffi"
              , gender = "Male"
              , age = Nothing
              , eye_color = "Dark brown"
              , hair_color = "Dark brown"
              }
            , { id = "fcb4a2ac-5e41-4d54-9bba-33068db083c27"
              , name = "Louis"
              , gender = "Male"
              , age = Just 30
              , eye_color = "Dark brown"
              , hair_color = "Dark brown"
              }
            , { id = "2cb76c15-772a-4cb3-9919-3652f56611d28"
              , name = "Charles"
              , gender = "Male"
              , age = Nothing
              , eye_color = "Dark brown"
              , hair_color = "Light brown"
              }
            ]
      }
    , { id = "cd3d059c-09f4-4ff3-8d63-bc765a5184fa"
      , title = "Howl's Moving Castle"
      , original_title = "ハウルの動く城"
      , original_title_romanised = "Hauru no ugoku shiro"
      , description = "When Sophie, a shy young woman, is cursed with an old body by a spiteful witch, her only chance of breaking the spell lies with a self-indulgent yet insecure young wizard and his companions in his legged, walking home."
      , director = "Hayao Miyazaki"
      , producer = "Toshio Suzuki"
      , release_date = 2004
      , running_time = 119
      , rt_score = 87
      , people =
            [ { id = "05d8d01b-0c2f-450e-9c55-aa0daa3483829"
              , name = "Motro"
              , gender = "Male"
              , age = Nothing
              , eye_color = "Dark brown"
              , hair_color = "None"
              }
            ]
      }
    ]
