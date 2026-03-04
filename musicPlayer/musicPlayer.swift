//
//  musicPlayer.swift
//  musicPlayer
//
//  Created by wearrier on 2026/02/24.
//

import SwiftUI
import Foundation
import AVFoundation
internal import Combine

struct ListMusic : Identifiable, Hashable
{
    var id: [String] = []
}

internal final class musicPlayer: NSObject, ObservableObject
{
    //プレイヤー
    @Published var player: AVAudioPlayer? = nil
    //ファイルパス
    @Published var url: String = ""
    @Published var listOfName: String = ""
    //タイマー
    @Published var timer: Timer? = nil
    @Published var elapsedSeconds: Double = 0.0
    @Published var durationTime: Double = 0.0
    //ファイルのリスト
    @Published var fileList: [String] = []
    @Published var index: Int = 0
    
    //ランダム要素オン／オフ
    @Published var isRandom: Bool = false
    
    //ループ設定
    @Published var isLoop: Bool = false
    
    @Published var isEditing: Bool = false
    
    override init ()
    {
        let player = AVAudioPlayer()
        self.player = player
        
        let timer = Timer()
        self.timer = timer
        
        super.init()
    }

    //再生処理
    func play()
    {
        //プレイリストが存在しない場合はエラー
        if fileList.isEmpty == true
        {
            print ("ファイルがありません。")
            return
        }
        
        //プレイリストが存在していれば再生
        else if fileList.isEmpty == false
        {
            
            if(isRandom == true)
            {
                index = Int.random(in: 0..<fileList.count)
            }
            
            listOfName = url + "/" + fileList[index]
            
            //再生処理
            let playerURL = URL(fileURLWithPath: listOfName)
            do
            {
                player?.stop()
                print(listOfName)
                player = try AVAudioPlayer(contentsOf: playerURL)
                Loop()
                if(player?.isPlaying == false)
                {
                    player?.play()
                    //ファイルの最終端を取得
                    durationTime = player!.duration
                }
            }
            catch
            {
                print ("Error loading audio file[Error: \(error)]")
            }
        }
        //再生時間取得
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true)
        {
            _ in
            self.elapsedSeconds = self.player!.currentTime
        }
    }
    
    //停止処理
    func stop()
    {
        player?.stop()
        player?.currentTime = 0.0
    }
    
    //プレイリスト生成
    func playlistAdd()
    {
        let fileManager = FileManager.default
        
        do
        {
            self.fileList = try fileManager.contentsOfDirectory(atPath: url)
            print("\(self.fileList)")
        }
        catch
        {
            print("Error retrieving files from directory.")
            return
        }
    }
    
    //ループ
    func Loop()
    {
        player?.numberOfLoops = isLoop ? -1 : 0
    }
    //次
    func nextPlay()
    {
        if(index == fileList.endIndex - 1)
        {
            index = fileList.startIndex - 1
        }
        
        if(index >= fileList.startIndex - 1)
        {
            index += 1
        }
    }
    //戻る
    func backPlay()
    {
        if(index == fileList.startIndex)
        {
            index = fileList.endIndex
        }
        
        if(index <= fileList.endIndex)
        {
            index -= 1
        }
    }
}
