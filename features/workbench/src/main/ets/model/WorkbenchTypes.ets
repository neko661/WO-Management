export interface TodoItem {
  id: number;
  type: string;
  title: string;
  description: string;
  count: number;
  color: string;
}

export interface QuickEntry {
  id: number;
  label: string;
  bgColor: string;
  iconColor: string;
  icon: Resource;
}

export interface MenuCard {
  id: number;
  title: string;
  description: string;
  icon: Resource;
  iconBg: string;
  iconColor: string;
}