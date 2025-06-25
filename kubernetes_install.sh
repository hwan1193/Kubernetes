#!/bin/bash
set -euo pipefail

echo "🚫 20. 스왑 비활성화"
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "🧩 22. 커널 모듈 설정"
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

echo "🧩 23~24. 커널 모듈 로드"
sudo modprobe overlay
sudo modprobe br_netfilter

echo "⚙️ 25. sysctl 네트워크 설정"
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

echo "⚙️ 26. sysctl 설정 적용"
sudo sysctl --system

echo "📦 27. containerd 설치"
sudo apt install -y containerd

echo "📁 28. containerd 설정 디렉토리 생성"
sudo mkdir -p /etc/containerd

echo "⚙️ 29. containerd 기본 설정 생성"
sudo containerd config default | sudo tee /etc/containerd/config.toml > /dev/null

echo "⚙️ 30. SystemdCgroup 설정 변경"
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

echo "🔁 31. containerd 재시작"
sudo systemctl restart containerd

echo "📌 32. containerd 부팅시 자동시작 설정"
sudo systemctl enable containerd

echo "📦 33. Kubernetes APT 필수 패키지 설치"
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl

echo "🔐 38~39. Kubernetes 공식 GPG 키 및 keyring 저장"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "📦 40. Kubernetes 저장소 추가"
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "🔄 41. APT 업데이트"
sudo apt update

echo "📦 42. kubelet, kubeadm, kubectl 설치"
sudo apt install -y kubelet kubeadm kubectl

echo "🔒 43. kubelet, kubeadm, kubectl 버전 고정"
sudo apt-mark hold kubelet kubeadm kubectl

echo "✅ Kubernetes 노드 설치 완료"