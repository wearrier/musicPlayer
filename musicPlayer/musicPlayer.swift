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

class musicPlayer: NSObject, ObservableObject
{
   //プレイヤー
    @Published var player: AVAudioPlayer?

    //ヴィジュアライザ
    @Published var leftPower: Float = -160
    @Published var rightPower: Float = -160
    @Published var leftSample: [CGFloat] = Array(repeating: 0, count: 30)
    @Published var rightSample: [CGFloat]  = Array(repeating: 0, count: 30)
    @Published var left: CGFloat
    @Published var right: CGFloat

    //ファイルパス
    @Published var url: String = ""
    @Published var listOfName: String = ""
    //タイマー
    @Published var timer: Timer?
    @Published var elapsedSeconds: Double = 0.0
    @Published var durationTime: Double = 0.0
    //ファイルのリスト
    @Published var fileList: [String] = []
    @Published var Index: Int = 0
    
    //ランダム要素オン／オフ
    @Published var isRandom: Bool = false
    
    //ループ設定
    @Published var isLoop: Bool = false
    
    override init()
    {
        let player = AVAudioPlayer()
        self.player = player
        
        let timer = Timer()
        self.timer = timer
        
        left = 0
        right = 0
        
        super.init()
    }
    
    //再生処理
    func play(_ index: Int)
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
            // Indexが -1 以下になっていた場合 0 に戻す
            if Index <= -1
            {
                Index = 0
                return
            }
            
            Index = Int(index)
            
            listOfName = url + "/" + fileList[Index]
            
            //再生処理
            let playerURL = URL(fileURLWithPath: listOfName)
            do
            {
                print(listOfName)
                player = try AVAudioPlayer(contentsOf: playerURL)
                if(player?.isPlaying == false)
                {
                    player?.delegate = self
                    player?.play()
                    //ファイルの最終端を取得
                    durationTime = player!.duration
                }
                if player?.isPlaying == true
                {
                    self.player?.isMeteringEnabled = true
                }
                if player?.isPlaying == false
                {
                    self.player?.isMeteringEnabled = false
                }
            }
            catch
            {
                print ("Error loading audio file[Error: \(error)]")
                nextPlay()
            }
        }
        //再生時間取得
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true)
        {
            _ in
            //バグ回避のためのコード
            if self.player?.currentTime == 0 && self.player?.duration == 0 || self.elapsedSeconds == 0 && self.durationTime == 0
            {
                return
            }
            else
            {
                self.updateVisualizer()
                self.elapsedSeconds = self.player!.currentTime
            }
        }
    }
    
    //停止処理
    func stop()
    {
        player?.stop()
        player?.currentTime = 0.0
    }
    
    //プレイリスト生成
    func playlistAdd(contentsOf: String)
    {
        let fileManager = FileManager.default
        
        //隠しファイルを取得しないようにフィルタリング処理（例：.DS_Store）
        do
        {
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: contentsOf, isDirectory: &isDir)
            {
                if isDir.boolValue == true
                {
                    self.fileList = try fileManager.contentsOfDirectory(atPath: contentsOf)
                        .filter { !$0.hasPrefix(".DS_Store") && !$0.StartsWith(".") }
                }
                else
                {
                    print("フォルダではありません")
                }
            }
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
        if isLoop == true
        {
            player?.numberOfLoops = -1
        }
        if isLoop == false
        {
            player?.numberOfLoops = 0
        }
    }
    //次
    func nextPlay()
    {
        if(Index == fileList.endIndex - 1)
        {
            Index = fileList.startIndex - 1
        }
        
        if(Index >= fileList.startIndex - 1)
        {
            Index += 1
        }
    }
    //戻る
    func backPlay()
    {
        if(Index == fileList.startIndex)
        {
            Index = fileList.endIndex
        }
        
        if(Index <= fileList.endIndex)
        {
            Index -= 1
        }
    }
    
    func updateVisualizer()
    {
        player?.updateMeters()

        leftPower = player?.peakPower(forChannel: 0) ?? -160
        rightPower = player?.peakPower(forChannel: 1) ?? -160

        elapsedSeconds = player?.currentTime ?? 0.0
    }

    func normalized(_ power: Float) -> CGFloat
    {
        let mindb: Float = -60
        let Normalized = (power - mindb) / (0 - mindb)
        
        return CGFloat(max(0, min(Normalized, 1)))
    }
}

extension musicPlayer: AVAudioPlayerDelegate
{
    //終端まで来たら、条件による再生
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        //ループ再生
        if isLoop == true
        {
            Loop()
        }
        //順次再生
        if isLoop == false
        {
            Loop()
            nextPlay()
        }
        //ランダム再生
        if(isRandom == true)
        {
            self.Index = Int.random(in: 0..<self.fileList.count)
        }
        play(Index)
    }
    
    //再生開始した際にインデックスがずれていないかチェック
    func audioPlayerItemDidPlayToEndTime(_ player: AVPlayerItem)
    {
        if player.status == .readyToPlay
        {
            if Index == Index
            {
                play(Index)
            }
        }
    }
}
